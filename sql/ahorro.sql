BEGIN;

ALTER TABLE descuentos_sucursal
    ADD COLUMN IF NOT EXISTS precio_real  numeric(12, 2) CHECK (precio_real > 0),
    ADD COLUMN IF NOT EXISTS precio_promo numeric(12, 2) CHECK (precio_promo >= 0);

CREATE TABLE IF NOT EXISTS uso_promo (
    id_uso       serial PRIMARY KEY,
    id_usuario   int NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_descuento int REFERENCES descuentos_sucursal(id_descuento) ON DELETE SET NULL,
    ahorro       numeric(12, 2) NOT NULL CHECK (ahorro > 0),
    fecha        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS uso_promo_usuario_fecha ON uso_promo (id_usuario, fecha);

COMMIT;
