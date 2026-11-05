import "dotenv/config";
import express from "express";
import cors from "cors";
import { pathToFileURL } from "node:url";
import router from "./routes/routes.js";
import { db } from "./db.js";

const app = express();

// Orígenes (fronts) que pueden pedirle cosas al back. Se configuran en la variable
// CORS_ORIGINS separados por coma; si no está, se usan el front local y el de Vercel.
const ORIGENES_PERMITIDOS = (process.env.CORS_ORIGINS || "http://localhost:5173,https://sumatoria-beryl.vercel.app")
    .split(",")
    .map((origen) => origen.trim().replace(/\/$/, ""))
    .filter(Boolean);

app.use(cors({
    // Los pedidos sin "origin" (Postman, curl, el propio servidor) se dejan pasar
    origin: (origen, callback) => callback(null, !origen || ORIGENES_PERMITIDOS.includes(origen))
}));

// Las imágenes (logo, portada, foto) llegan como texto base64, por eso el límite es más grande
app.use(express.json({ limit: "10mb" }));

// Si el pedido no trae body, se usa un objeto vacío (así no falla al leer req.body.algo)
app.use((req, res, next) => {
    req.body ??= {};
    next();
});

app.use("/", router);

// Cualquier ruta que no exista
app.use((req, res) => {
    res.status(404).json({ mensaje: `No existe la ruta ${req.method} ${req.path}` });
});

// Errores que no se atajaron en los controllers (ej: un JSON mal escrito en el body)
app.use((error, req, res, next) => {
    if (error.type === "entity.parse.failed") {
        return res.status(400).json({ mensaje: "El body no es un JSON válido" });
    }
    if (error.type === "entity.too.large") {
        return res.status(413).json({ mensaje: "El pedido es demasiado grande (¿una imagen muy pesada?)" });
    }
    console.error(error);
    res.status(500).json({ mensaje: "Error interno del servidor" });
});

// En Vercel no se llama a listen: Vercel importa la app y la ejecuta como función.
// Solo se levanta el servidor cuando se corre este archivo directo (npm start / npm run dev).
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Servidor corriendo en http://localhost:${PORT}`);
        db.query("SELECT 1").catch((error) => console.error("No se pudo conectar con la base:", error.message));
    });
}

export default app;
