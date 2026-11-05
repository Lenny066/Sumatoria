BEGIN;

ALTER TABLE descuentos_sucursal
    ADD COLUMN IF NOT EXISTS porcentaje numeric(5, 2) CHECK (porcentaje > 0 AND porcentaje < 100);

COMMIT;
