// Valores fijos que usa el front. Si el front agrega una opción, se agrega acá también.
export const DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];

export const RUBROS = [
    "Gastronomía",
    "Indumentaria",
    "Supermercado",
    "Electrodomésticos",
    "Farmacia",
    "Librería",
    "Otro"
];

export const MARCAS = ["visa", "mastercard", "amex", "cabal"];
export const TIPOS_TARJETA = ["debito", "credito"];
export const TIPOS_SIMPLES = ["efectivo", "transferencia", "mercadopago"];

const HORA = /^([01]\d|2[0-3]):[0-5]\d$/; // formato "09:30"
const FECHA = /^\d{4}-\d{2}-\d{2}$/;      // formato "2026-11-30"

export function textoValido(valor) {
    return typeof valor === "string" && valor.trim() !== "";
}

// [{ dia: "Lunes", abierto: true, desde: "09:00", hasta: "18:00" }, ...]
export function horariosValidos(horarios) {
    return (
        Array.isArray(horarios) &&
        horarios.every(
            (h) =>
                h &&
                DIAS.includes(h.dia) &&
                typeof h.abierto === "boolean" &&
                HORA.test(h.desde) &&
                HORA.test(h.hasta)
        )
    );
}

// ["Lunes", "Martes"]
export function diasValidos(dias) {
    return Array.isArray(dias) && dias.every((dia) => DIAS.includes(dia));
}

export function precioValido(precio) {
    return precio === null || precio === undefined || (typeof precio === "number" && Number.isFinite(precio) && precio >= 0);
}

export function preciosValidos(precioReal, precioPromo) {
    if (!precioValido(precioReal) || !precioValido(precioPromo)) return false;
    const sinReal = precioReal === null || precioReal === undefined;
    const sinPromo = precioPromo === null || precioPromo === undefined;
    if (sinReal && sinPromo) return true;
    if (sinReal || sinPromo) return false;
    return precioReal > 0 && precioPromo < precioReal;
}

export function porcentajeValido(porcentaje) {
    return (
        porcentaje === null ||
        porcentaje === undefined ||
        (typeof porcentaje === "number" && Number.isFinite(porcentaje) && porcentaje > 0 && porcentaje < 100)
    );
}

// "2026-11-30" o null
export function fechaValida(fecha) {
    return fecha === null || fecha === undefined || fecha === "" || FECHA.test(fecha);
}

// [{ tipo: "efectivo" }, { tipo: "debito", marca: "visa", banco: null }, ...]
export function mediosPagoValidos(medios) {
    return (
        Array.isArray(medios) &&
        medios.every((medio) => {
            if (!medio) return false;
            if (TIPOS_SIMPLES.includes(medio.tipo)) return true;
            if (!TIPOS_TARJETA.includes(medio.tipo)) return false;
            const marcaOk = medio.marca === null || medio.marca === undefined || MARCAS.includes(medio.marca);
            const bancoOk = medio.banco === null || medio.banco === undefined || typeof medio.banco === "string";
            return marcaOk && bancoOk;
        })
    );
}
