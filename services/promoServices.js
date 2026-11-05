import { db } from "../db.js";
import { crearError } from "../utils/manejarError.js";
import { aPrecio, MEDIOS_DE_PROMO, MEDIOS_NUEVOS, mediosDeFila, mediosParaGuardar } from "./negocioServices.js";
import { notificarPromoNueva } from "./notificacionServices.js";

const SUCURSAL_DE_EMPRESA = "(SELECT id_sucursal FROM sucursal WHERE id_empresa = $1 ORDER BY id_sucursal LIMIT 1)";

const MEDIOS_INSERTADOS = `COALESCE((
    SELECT json_agg(json_build_object('tipo', tipo, 'red_pago', red_pago, 'emisor', emisor) ORDER BY id_aplican)
    FROM medios
), '[]') AS medios`;

function aPromoNegocio(fila) {
    return {
        id: String(fila.id_descuento),
        titulo: fila.titulo,
        descripcion: fila.descripcion,
        imagen: fila.imagen ?? undefined,
        dias: fila.dias,
        mediosPago: mediosDeFila(fila),
        vence: fila.vence ?? undefined,
        estado: fila.estado,
        precioReal: aPrecio(fila.precio_real),
        precioPromo: aPrecio(fila.precio_promo),
        porcentaje: aPrecio(fila.porcentaje)
    };
}

function avisarSeguidores(idSucursal, idDescuento, titulo) {
    notificarPromoNueva(idSucursal, idDescuento, titulo).catch((error) =>
        console.error("No se pudo avisar a los seguidores:", error.message)
    );
}

export const listarMisPromos = async (idEmpresa) => {
    const resultado = await db.query(
        `SELECT d.*, ${MEDIOS_DE_PROMO}
         FROM descuentos_sucursal d
         WHERE d.id_sucursal = ${SUCURSAL_DE_EMPRESA}
         ORDER BY d.fecha DESC`,
        [idEmpresa]
    );
    return resultado.rows.map(aPromoNegocio);
};

export const crearPromo = async (idEmpresa, datos) => {
    const estado = datos.estado ?? "activa";
    const titulo = datos.titulo.trim();

    const resultado = await db.query(
        `WITH nueva AS (
            INSERT INTO descuentos_sucursal
                (id_sucursal, titulo, descripcion, imagen, dias, vence, estado, precio_real, precio_promo, porcentaje)
            SELECT s.id_sucursal, $2, $3, $4, $5, $6, $7, $8, $9, $10
            FROM (SELECT ${SUCURSAL_DE_EMPRESA} AS id_sucursal) s
            WHERE s.id_sucursal IS NOT NULL
            RETURNING *
         ),
         medios AS (
            INSERT INTO aplican (id_descuento, tipo, red_pago, emisor)
            SELECT nueva.id_descuento, m.tipo, m.red_pago, m.emisor
            FROM nueva, ${MEDIOS_NUEVOS.replace("$MEDIOS", "$11")}
            ORDER BY m.orden
            RETURNING *
         )
         SELECT nueva.*, ${MEDIOS_INSERTADOS}
         FROM nueva`,
        [
            idEmpresa,
            titulo,
            datos.descripcion ?? "",
            datos.imagen || null,
            datos.dias,
            datos.vence || null,
            estado,
            datos.precioReal ?? null,
            datos.precioPromo ?? null,
            datos.porcentaje ?? null,
            mediosParaGuardar(datos.mediosPago)
        ]
    );

    const fila = resultado.rows[0];
    if (!fila) throw crearError(404, "Negocio no encontrado");

    if (estado === "activa") avisarSeguidores(fila.id_sucursal, fila.id_descuento, titulo);
    return aPromoNegocio(fila);
};

export const editarPromo = async (idEmpresa, idDescuento, datos) => {
    const cambiaMedios = Array.isArray(datos.mediosPago);
    const cambiaPrecios = datos.precioReal !== undefined || datos.precioPromo !== undefined;

    const resultado = await db.query(
        `WITH previa AS (
            SELECT d.id_descuento, d.estado
            FROM descuentos_sucursal d
            WHERE d.id_descuento = $2 AND d.id_sucursal = ${SUCURSAL_DE_EMPRESA}
         ),
         cambiada AS (
            UPDATE descuentos_sucursal d
            SET titulo       = COALESCE($3, d.titulo),
                descripcion  = COALESCE($4, d.descripcion),
                imagen       = CASE WHEN $5::boolean THEN $6 ELSE d.imagen END,
                dias         = COALESCE($7, d.dias),
                vence        = CASE WHEN $8::boolean THEN $9::date ELSE d.vence END,
                estado       = COALESCE($10, d.estado),
                precio_real  = CASE WHEN $11::boolean THEN $12::numeric ELSE d.precio_real END,
                precio_promo = CASE WHEN $11::boolean THEN $13::numeric ELSE d.precio_promo END,
                porcentaje   = CASE WHEN $14::boolean THEN $15::numeric ELSE d.porcentaje END
            FROM previa
            WHERE d.id_descuento = previa.id_descuento
            RETURNING d.*
         ),
         borrados AS (
            DELETE FROM aplican
            WHERE $16::boolean AND id_descuento IN (SELECT id_descuento FROM previa)
         ),
         medios AS (
            INSERT INTO aplican (id_descuento, tipo, red_pago, emisor)
            SELECT previa.id_descuento, m.tipo, m.red_pago, m.emisor
            FROM previa, ${MEDIOS_NUEVOS.replace("$MEDIOS", "$17")}
            WHERE $16::boolean
            ORDER BY m.orden
            RETURNING *
         )
         SELECT cambiada.*, previa.estado AS estado_anterior,
                CASE WHEN $16::boolean
                     THEN (SELECT ${MEDIOS_INSERTADOS.replace(" AS medios", "")})
                     ELSE ${MEDIOS_DE_PROMO.replace(" AS medios", "").replaceAll("d.id_descuento", "cambiada.id_descuento")}
                END AS medios
         FROM cambiada, previa`,
        [
            idEmpresa,
            idDescuento,
            datos.titulo?.trim() ?? null,
            datos.descripcion ?? null,
            datos.imagen !== undefined,
            datos.imagen || null,
            datos.dias ?? null,
            datos.vence !== undefined,
            datos.vence || null,
            datos.estado ?? null,
            cambiaPrecios,
            datos.precioReal ?? null,
            datos.precioPromo ?? null,
            datos.porcentaje !== undefined,
            datos.porcentaje ?? null,
            cambiaMedios,
            mediosParaGuardar(cambiaMedios ? datos.mediosPago : [])
        ]
    );

    const fila = resultado.rows[0];
    if (!fila) throw crearError(404, "Promoción no encontrada");

    if (fila.estado_anterior === "pausada" && fila.estado === "activa") {
        avisarSeguidores(fila.id_sucursal, fila.id_descuento, fila.titulo);
    }
    return aPromoNegocio(fila);
};

export const borrarPromo = async (idEmpresa, idDescuento) => {
    const resultado = await db.query(
        `DELETE FROM descuentos_sucursal
         WHERE id_descuento = $2 AND id_sucursal = ${SUCURSAL_DE_EMPRESA}`,
        [idEmpresa, idDescuento]
    );
    if (resultado.rowCount === 0) {
        throw crearError(404, "Promoción no encontrada");
    }
};
