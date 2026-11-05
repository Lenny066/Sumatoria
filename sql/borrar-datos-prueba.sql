BEGIN;

DELETE FROM empresa WHERE mail LIKE '%@prueba.sumatoria.com';

COMMIT;
