import { db } from "../db.js";
import { crearError } from "../utils/manejarError.js";
import { tarjetasDeUsuario } from "./tarjetaServices.js";

// Condición SQL de "promo vigente": activa y no vencida
export const PROMO_VIGENTE = "d.estado = 'activa' AND (d.vence IS NULL OR d.vence >= CURRENT_DATE)";

// ---------------------------------------------------------------------
// Formatos que espera el front
// ---------------------------------------------------------------------

// Fila de la tabla aplican -> medio de pago del front
export function aMedioPago(fila) {
    if (fila.tipo === "debito" || fila.tipo === "credito") {
        return { tipo: fila.tipo, marca: fila.red_pago, banco: fila.emisor };
    }
    return { tipo: fila.tipo };
}

// Fila de descuentos_sucursal -> promoción del front
export function aPromocion(fila, mediosPago) {
    return {
        id: String(fila.id_descuento),
        descuento: fila.titulo,
        descripcion: fila.descripcion,
        imagen: fila.imagen ?? undefined,
        dias: fila.dias,
        mediosPago,
        vence: fila.vence ?? undefined,
        precioReal: aPrecio(fila.precio_real),
        precioPromo: aPrecio(fila.precio_promo),
        porcentaje: aPrecio(fila.porcentaje)
    };
}

export function aPrecio(valor) {
    return valor === null || valor === undefined ? undefined : Number(valor);
}

export const MEDIOS_DE_PROMO = `COALESCE((
    SELECT json_agg(json_build_object('tipo', a.tipo, 'red_pago', a.red_pago, 'emisor', a.emisor) ORDER BY a.id_aplican)
    FROM aplican a
    WHERE a.id_descuento = d.id_descuento
), '[]') AS medios`;

export function mediosDeFila(fila) {
    return (fila.medios ?? []).map(aMedioPago);
}

export function mediosParaGuardar(mediosPago) {
    return JSON.stringify(
        (mediosPago ?? []).map((medio) => {
            const esTarjeta = medio.tipo === "debito" || medio.tipo === "credito";
            return {
                tipo: medio.tipo,
                red_pago: esTarjeta ? medio.marca || null : null,
                emisor: esTarjeta ? medio.banco || null : null
            };
        })
    );
}

export const MEDIOS_NUEVOS = `ROWS FROM (jsonb_to_recordset($MEDIOS::jsonb) AS (tipo text, red_pago text, emisor text))
    WITH ORDINALITY AS m(tipo, red_pago, emisor, orden)`;

// Medios de pago de varias promos de una sola vez: { idPromo: [medios] }
export async function mediosPagoDePromos(idsPromos) {
    const porPromo = {};
    if (idsPromos.length === 0) return porPromo;

    const resultado = await db.query(
        `SELECT id_descuento, tipo, red_pago, emisor
         FROM aplican
         WHERE id_descuento = ANY($1::int[])
         ORDER BY id_aplican`,
        [idsPromos]
    );

    for (const fila of resultado.rows) {
        porPromo[fila.id_descuento] ??= [];
        porPromo[fila.id_descuento].push(aMedioPago(fila));
    }
    return porPromo;
}

// ¿La promo sirve con alguna de las tarjetas del usuario? (misma lógica que el front)
export function sirveConTarjetas(promo, tarjetas) {
    if (tarjetas.length === 0 || promo.mediosPago.length === 0) return true;

    return promo.mediosPago.some((medio) => {
        if (medio.tipo !== "debito" && medio.tipo !== "credito") return true;
        return tarjetas.some(
            (tarjeta) =>
                tarjeta.tipo === medio.tipo &&
                (!medio.marca || medio.marca === tarjeta.marca) &&
                (!medio.banco || medio.banco === tarjeta.banco)
        );
    });
}

// Tarjetas del que hace el pedido (solo si es un usuario logueado)
export async function tarjetasDeQuienPide(sesion) {
    if (!sesion || sesion.rol !== "usuario") return [];
    return tarjetasDeUsuario(sesion.id);
}

// ---------------------------------------------------------------------
// Arma los negocios completos (con horarios y promociones) a partir de
// una lista de ids de sucursal, respetando el orden de la lista.
// ---------------------------------------------------------------------
export async function armarNegocios(idsSucursales, tarjetasPedidas = []) {
    if (idsSucursales.length === 0) return [];

    const [sucursales, promos, tarjetas] = await Promise.all([
        db.query(
            `SELECT s.id_sucursal, s.direccion, s.lat, s.lng, s.horarios,
                    e.nombre, e.rubro, e.logo, e.portada, e.descripcion
             FROM sucursal s
             JOIN empresa e ON e.id_empresa = s.id_empresa
             WHERE s.id_sucursal = ANY($1::int[])`,
            [idsSucursales]
        ),
        db.query(
            `SELECT d.*, ${MEDIOS_DE_PROMO}
             FROM descuentos_sucursal d
             WHERE d.id_sucursal = ANY($1::int[]) AND ${PROMO_VIGENTE}
             ORDER BY d.fecha DESC`,
            [idsSucursales]
        ),
        tarjetasPedidas
    ]);

    const negocios = sucursales.rows.map((s) => ({
        id: String(s.id_sucursal),
        nombre: s.nombre,
        rubro: s.rubro,
        logo: s.logo ?? undefined,
        portada: s.portada ?? undefined,
        descripcion: s.descripcion,
        direccion: s.direccion,
        lat: s.lat,
        lng: s.lng,
        horarios: s.horarios,
        promociones: promos.rows
            .filter((p) => p.id_sucursal === s.id_sucursal)
            .map((p) => aPromocion(p, mediosDeFila(p)))
            .filter((promo) => sirveConTarjetas(promo, tarjetas))
    }));

    // Devolver en el mismo orden en que se pidieron
    return idsSucursales
        .map((id) => negocios.find((n) => n.id === String(id)))
        .filter(Boolean);
}

// ---------------------------------------------------------------------
// Endpoints públicos
// ---------------------------------------------------------------------

// GET /negocios y GET /negocios?buscar=texto
export const listarNegocios = async (buscar, sesion) => {
    let consulta;

    if (buscar && buscar.trim() !== "") {
        // Busca en nombre, rubro, descripción, dirección y en las promos
        // (unaccent no siempre está instalado, por eso se usa ILIKE común)
        const patron = `%${buscar.trim()}%`;
        consulta = db.query(
            `SELECT DISTINCT s.id_sucursal
             FROM sucursal s
             JOIN empresa e ON e.id_empresa = s.id_empresa
             LEFT JOIN descuentos_sucursal d ON d.id_sucursal = s.id_sucursal AND ${PROMO_VIGENTE}
             WHERE e.nombre ILIKE $1 OR e.rubro ILIKE $1 OR e.descripcion ILIKE $1
                OR s.direccion ILIKE $1 OR d.titulo ILIKE $1 OR d.descripcion ILIKE $1`,
            [patron]
        );
    } else {
        consulta = db.query("SELECT id_sucursal FROM sucursal ORDER BY id_sucursal");
    }

    const [resultado, tarjetas] = await Promise.all([consulta, tarjetasDeQuienPide(sesion)]);
    return armarNegocios(resultado.rows.map((f) => f.id_sucursal), tarjetas);
};

// GET /negocios/:id
export const obtenerNegocio = async (idSucursal, sesion) => {
    const [negocio] = await armarNegocios([idSucursal], tarjetasDeQuienPide(sesion));

    if (!negocio) throw crearError(404, "Negocio no encontrado");
    return negocio;
};

// GET /inicio -> { hot, sugeridas, elegidos, nuevos }
export const seccionesInicio = async (sesion) => {
    const LIMITE = 10;
    const idUsuario = sesion?.rol === "usuario" ? sesion.id : null;

    const [tarjetas, hot, elegidos, nuevos, sugeridas] = await Promise.all([
        tarjetasDeQuienPide(sesion),
        db.query(
            `SELECT d.id_sucursal, COUNT(f.id_usuario) AS favoritos, COUNT(DISTINCT d.id_descuento) AS promos
             FROM descuentos_sucursal d
             LEFT JOIN favea_sucursal f ON f.id_descuento = d.id_descuento
             WHERE ${PROMO_VIGENTE}
             GROUP BY d.id_sucursal
             ORDER BY favoritos DESC, promos DESC
             LIMIT $1`,
            [LIMITE]
        ),
        db.query(
            `SELECT s.id_sucursal, COUNT(sg.id_usuario) AS seguidores
             FROM sucursal s
             LEFT JOIN seguimiento sg ON sg.id_sucursal = s.id_sucursal
             GROUP BY s.id_sucursal
             HAVING COUNT(sg.id_usuario) > 0
             ORDER BY seguidores DESC
             LIMIT $1`,
            [LIMITE]
        ),
        db.query("SELECT id_sucursal FROM sucursal ORDER BY creado_en DESC LIMIT $1", [LIMITE]),
        db.query(
            `WITH b AS (
                SELECT COALESCE((SELECT barrio FROM usuario WHERE id_usuario = $1), '') AS barrio
             )
             SELECT s.id_sucursal
             FROM sucursal s, b
             WHERE EXISTS (SELECT 1 FROM descuentos_sucursal d WHERE d.id_sucursal = s.id_sucursal AND ${PROMO_VIGENTE})
             ORDER BY (b.barrio <> '' AND s.direccion ILIKE '%' || b.barrio || '%') DESC, random()
             LIMIT $2`,
            [idUsuario, LIMITE]
        )
    ]);

    const ids = (resultado) => resultado.rows.map((f) => f.id_sucursal);
    const todos = [...new Set([...ids(hot), ...ids(sugeridas), ...ids(elegidos), ...ids(nuevos)])];
    const negocios = new Map((await armarNegocios(todos, tarjetas)).map((n) => [n.id, n]));
    const elegir = (resultado) => ids(resultado).map((id) => negocios.get(String(id))).filter(Boolean);

    return {
        hot: elegir(hot),
        sugeridas: elegir(sugeridas),
        elegidos: elegir(elegidos),
        nuevos: elegir(nuevos)
    };
};
