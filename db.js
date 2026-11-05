import pkg from "pg";
import dotenv from "dotenv";

dotenv.config();

const { Pool, types } = pkg;

// Las columnas de tipo DATE (ej: "vence") se devuelven como texto "2026-11-30",
// que es el formato que usa el front, en vez de un objeto Date.
types.setTypeParser(1082, (valor) => valor);

export const db = new Pool({
    connectionString: process.env.DATABASE_URL,
    // En Vercel puede haber varias copias de la función a la vez y cada una tiene su pool,
    // así que se usan pocas conexiones por copia para no agotar las de la base.
    max: process.env.VERCEL ? 3 : 10,
    idleTimeoutMillis: process.env.VERCEL ? 30000 : 240000,
    keepAlive: true
});

db.on("error", (error) => {
    console.error("Se cortó una conexión con la base, se va a abrir otra:", error.message);
});
