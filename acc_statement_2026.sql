-- =============================================================
-- Script de creación: clients y statements
-- Origen de los datos: acc_statement_2026.csv (clientes)
--                      acc_statements.csv     (movimientos)
-- SGBD: PostgreSQL 17
-- =============================================================

BEGIN;

DROP TABLE IF EXISTS statements;
DROP TABLE IF EXISTS clients;

-- -------------------------------------------------------------
-- Tabla clients
-- -------------------------------------------------------------
CREATE TABLE clients (
    id_client   SERIAL       PRIMARY KEY,
    nom         VARCHAR(50)  NOT NULL,
    cognoms     VARCHAR(100) NOT NULL,
    id_fiscal   VARCHAR(15)  NOT NULL UNIQUE
);

-- -------------------------------------------------------------
-- Tabla statements (movimientos del extracto)
-- data_fi y saldo son NULL en los movimientos DEVUELTO / PENDIENTE
-- -------------------------------------------------------------
CREATE TABLE statements (
    id_statement     SERIAL         PRIMARY KEY,
    id_client        INTEGER        NOT NULL
                     REFERENCES clients (id_client)
                     ON UPDATE CASCADE ON DELETE RESTRICT,
    tipus_moviment   VARCHAR(30)    NOT NULL,
    producte         VARCHAR(30)    NOT NULL,
    data_inici       TIMESTAMP      NOT NULL,
    data_fi          TIMESTAMP,
    descripcio       VARCHAR(255)   NOT NULL,
    import           NUMERIC(12, 2) NOT NULL,
    comissio         NUMERIC(12, 2) NOT NULL DEFAULT 0,
    divisa           CHAR(3)        NOT NULL,
    estat            VARCHAR(20)    NOT NULL,
    saldo            NUMERIC(12, 2)
);

CREATE INDEX idx_statements_client_data ON statements (id_client, data_inici);

-- -------------------------------------------------------------
-- Datos: clients
-- -------------------------------------------------------------
INSERT INTO clients (id_client, nom, cognoms, id_fiscal) VALUES
    (1, 'Arnau', 'Perafita', '44555777J');

-- Ajustar la secuencia tras insertar ids explícitos
SELECT setval(pg_get_serial_sequence('clients', 'id_client'),
              (SELECT MAX(id_client) FROM clients));

-- -------------------------------------------------------------
-- Datos: statements (id_statement lo genera el SERIAL)
-- -------------------------------------------------------------
INSERT INTO statements (id_client, tipus_moviment, producte, data_inici, data_fi,
                        descripcio, import, comissio, divisa, estat, saldo) VALUES
    (1, 'Recargas', 'Actual', '2026-01-05 20:28', '2026-01-05 20:28', 'Recarga por transferencia bancaria', 5.00, 0.00, 'EUR', 'COMPLETADO', 20.37),
    (1, 'Transferir', 'Actual', '2026-01-06 11:33', '2026-01-06 11:33', 'RevPoints con Redondeo', -0.55, 0.00, 'EUR', 'COMPLETADO', 19.82),
    (1, 'Recargas', 'Actual', '2026-01-06 12:14', '2026-01-06 12:14', 'Recarga por transferencia bancaria', 15.00, 0.00, 'EUR', 'COMPLETADO', 34.82),
    (1, 'Pago con tarjeta', 'Actual', '2026-01-06 20:48', '2026-01-07 22:05', 'Renfe Rodalies', -1.40, 0.00, 'EUR', 'COMPLETADO', 33.42),
    (1, 'Recargas', 'Actual', '2026-01-07 11:01', '2026-01-07 11:01', 'Recarga por transferencia bancaria', 10.00, 0.00, 'EUR', 'COMPLETADO', 36.40),
    (1, 'Pago con tarjeta', 'Actual', '2026-01-09 20:35', NULL, 'Forn de Pa Can Josep', -0.93, 0.00, 'EUR', 'DEVUELTO', NULL),
    (1, 'Pago con tarjeta', 'Actual', '2026-01-29 13:21', '2026-01-30 13:49', 'Bicing', -0.50, 0.00, 'EUR', 'COMPLETADO', 21.52),
    (1, 'Cambio', 'Actual', '2026-03-05 09:05', '2026-03-05 09:05', 'Cambiado a GBP', -10.00, 0.10, 'EUR', 'COMPLETADO', 1.56),
    (1, 'Pago con tarjeta', 'Actual', '2026-04-09 10:37', NULL, 'Bicing', -4.76, 0.00, 'EUR', 'DEVUELTO', NULL),
    (1, 'Pago con tarjeta', 'Actual', '2026-07-17 13:20', NULL, 'Fruiteria Núria', -7.64, 0.00, 'EUR', 'DEVUELTO', NULL),
    (1, 'Pago con tarjeta', 'Actual', '2026-08-11 08:26', NULL, 'Fruiteria Núria', -7.93, 0.00, 'EUR', 'DEVUELTO', NULL),
    (1, 'Pago con tarjeta', 'Actual', '2026-09-21 13:50', NULL, 'Màquina vending Institut', -9.07, 0.00, 'EUR', 'PENDIENTE', NULL),
    (1, 'Transferir', 'Actual', '2026-12-07 13:18', '2026-12-07 13:18', 'RevPoints con Redondeo', -0.19, 0.00, 'EUR', 'COMPLETADO', 9.89),
    (1, 'Pago con tarjeta', 'Actual', '2026-12-07 17:27', '2026-12-08 21:06', 'Cafeteria L''Estació', -6.31, 0.00, 'EUR', 'COMPLETADO', 3.58),
    (1, 'Transferir', 'Actual', '2026-12-09 14:43', '2026-12-09 14:43', 'RevPoints con Redondeo', -0.57, 0.00, 'EUR', 'COMPLETADO', 3.01),
    (1, 'Recargas', 'Actual', '2026-12-10 18:48', '2026-12-10 18:48', 'Recarga por transferencia bancaria', 10.00, 0.00, 'EUR', 'COMPLETADO', 13.01),
    (1, 'Recargas', 'Actual', '2026-12-11 15:40', '2026-12-11 15:40', 'Recarga con Bizum', 10.00, 0.00, 'EUR', 'COMPLETADO', 17.87),
    (1, 'Pago con tarjeta', 'Actual', '2026-12-11 15:44', '2026-12-11 15:44', 'Bicing', -8.25, 0.00, 'EUR', 'COMPLETADO', 9.62),
    (1, 'Recargas', 'Actual', '2026-12-11 21:31', '2026-12-11 21:31', 'Recarga con tarjeta *4821', 10.00, 0.00, 'EUR', 'COMPLETADO', 19.62),
    (1, 'Pago con tarjeta', 'Actual', '2026-12-12 21:57', '2026-12-13 23:53', 'Bicing', -4.82, 0.00, 'EUR', 'COMPLETADO', 5.61),
    (1, 'Pago de Revolut', 'Actual', '2026-12-15 03:42', '2026-12-15 03:42', 'Plan Standard', -0.99, 0.00, 'EUR', 'COMPLETADO', 4.14),
    (1, 'Recargas', 'Actual', '2026-12-15 13:55', '2026-12-15 13:55', 'Recarga con tarjeta *4821', 10.00, 0.00, 'EUR', 'COMPLETADO', 14.14),
    (1, 'Pago con tarjeta', 'Actual', '2026-12-15 13:59', '2026-12-15 13:59', 'Bar Gràcia', -4.97, 0.00, 'EUR', 'COMPLETADO', 9.17),
    (1, 'Recargas', 'Actual', '2026-12-16 20:24', '2026-12-16 20:24', 'Recarga con Bizum', 10.00, 0.00, 'EUR', 'COMPLETADO', 16.47),
    (1, 'Pago con tarjeta', 'Actual', '2026-12-16 20:28', '2026-12-16 20:28', 'Bar La Cantonada', -9.01, 0.00, 'EUR', 'COMPLETADO', 7.46),
    (1, 'Transferir', 'Actual', '2026-12-16 22:14', '2026-12-16 22:14', 'RevPoints con Redondeo', -0.74, 0.00, 'EUR', 'COMPLETADO', 6.72),
    (1, 'Recargas', 'Actual', '2026-12-17 10:10', '2026-12-17 10:10', 'Recarga en efectivo', 10.00, 0.00, 'EUR', 'COMPLETADO', 16.72);

COMMIT;
