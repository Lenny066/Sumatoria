import { db } from "../db.js";
import { crearError } from "../utils/manejarError.js";
import { PROMO_VIGENTE } from "./negocioServices.js";

const ZONA = "America/Argentina/Buenos_Aires";

export const obtenerAhorro = async (idUsuario) => {
    const resultado = await db.query(
        `SELECT
            COALESCE(SUM(ahorro), 0) AS total,
            COALESCE(SUM(ahorro) FILTER (WHERE (fecha AT TIME ZONE $2) >= date_trunc('month', now() AT TIME ZONE $2)), 0) AS mes,
            COUNT(*) FILTER (WHERE (fecha AT TIME ZONE $2) >= date_trunc('month', now() AT TIME ZONE $2)) AS usos_mes
         FROM uso_promo
         WHERE id_usuario = $1`,
        [idUsuario, ZONA]
    );
    const fila = resultado.rows[0];
    return {
        total: Number(fila.total),
        mes: Number(fila.mes),
        usosMes: Number(fila.usos_mes)
    };
};

export const usarPromo = async (idUsuario, idDescuento, { ahorro: ahorroIndicado, sinDescuento }) => {
    const resultado = await db.query(
        `SELECT d.precio_real, d.precio_promo, d.porcentaje
         FROM descuentos_sucursal d
         WHERE d.id_descuento = $1 AND ${PROMO_VIGENTE}`,
        [idDescuento]
    );
    if (resultado.rows.length === 0) {
        throw crearError(404, "Promoción no encontrada");
    }

    const { precio_real, precio_promo, porcentaje } = resultado.rows[0];
    let ahorro;
    if (precio_real !== null && precio_promo !== null) {
        ahorro = Number(precio_real) - Number(precio_promo);
    } else if (porcentaje !== null) {
        if (!(typeof sinDescuento === "number" && Number.isFinite(sinDescuento) && sinDescuento > 0)) {
            throw crearError(400, "Contanos cuánto salía tu compra sin el descuento");
        }
        ahorro = (sinDescuento * Number(porcentaje)) / 100;
    } else {
        ahorro = ahorroIndicado;
    }

    if (!(typeof ahorro === "number" && Number.isFinite(ahorro) && ahorro > 0)) {
        throw crearError(400, "Contanos cuánto ahorraste con la promo");
    }
    ahorro = Math.round(ahorro * 100) / 100;

    await db.query(
        "INSERT INTO uso_promo (id_usuario, id_descuento, ahorro) VALUES ($1, $2, $3)",
        [idUsuario, idDescuento, ahorro]
    );

    return { ahorro, ...(await obtenerAhorro(idUsuario)) };
};

export const ahorroPorMes = async (idUsuario) => {
    const resultado = await db.query(
        `WITH meses AS (
            SELECT generate_series(
                date_trunc('month', now() AT TIME ZONE $2) - interval '11 months',
                date_trunc('month', now() AT TIME ZONE $2),
                interval '1 month'
            ) AS inicio
         )
         SELECT to_char(m.inicio, 'YYYY-MM') AS mes,
                COALESCE(SUM(u.ahorro), 0) AS ahorro,
                COUNT(u.id_uso) AS usos
         FROM meses m
         LEFT JOIN uso_promo u
            ON u.id_usuario = $1
           AND date_trunc('month', u.fecha AT TIME ZONE $2) = m.inicio
         GROUP BY m.inicio
         ORDER BY m.inicio DESC`,
        [idUsuario, ZONA]
    );
    return resultado.rows.map((fila) => ({
        mes: fila.mes,
        ahorro: Number(fila.ahorro),
        usos: Number(fila.usos)
    }));
};
