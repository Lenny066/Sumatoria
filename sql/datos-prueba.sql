BEGIN;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'cafe-esquina@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Café Esquina', 'cafe-esquina@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/cafe-esquina.svg', 'Gastronomía', 'Café de especialidad y pastelería casera en el corazón de Palermo.', 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Gorriti 4800, Palermo', -34.5893, -58.4318, '[{"dia":"Lunes","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Martes","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Miércoles","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Jueves","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Viernes","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Sábado","abierto":true,"desde":"08:00","hasta":"20:00"},{"dia":"Domingo","abierto":true,"desde":"08:00","hasta":"20:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '2x1 en cafés con leche', 'Pedí dos cafés con leche y pagá uno. Válido para consumir en el local.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']::text[], NULL, 'activa', 7000, 3500, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', 'visa', 'Banco Galicia'),
      (pro, 'credito', 'visa', 'Banco Galicia');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '15% OFF en toda la carta', 'Descuento en todo lo que consumas pagando con Mercado Pago.', ARRAY['Sábado', 'Domingo']::text[], NULL, 'activa', NULL, NULL, 15)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'mercadopago', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'la-fugazza@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('La Fugazza', 'la-fugazza@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/la-fugazza.svg', 'Gastronomía', 'Pizzería porteña de toda la vida: a la piedra, fugazzeta y fainá.', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Corrientes 3900, Almagro', -34.604, -58.422, '[{"dia":"Lunes","abierto":false,"desde":"12:00","hasta":"00:00"},{"dia":"Martes","abierto":true,"desde":"12:00","hasta":"00:00"},{"dia":"Miércoles","abierto":true,"desde":"12:00","hasta":"00:00"},{"dia":"Jueves","abierto":true,"desde":"12:00","hasta":"00:00"},{"dia":"Viernes","abierto":true,"desde":"12:00","hasta":"00:00"},{"dia":"Sábado","abierto":true,"desde":"12:00","hasta":"00:00"},{"dia":"Domingo","abierto":true,"desde":"12:00","hasta":"00:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Grande de muzza + fainá a $9.000', 'Pizza grande de muzzarella con dos porciones de fainá.', ARRAY['Martes', 'Miércoles', 'Jueves']::text[], NULL, 'activa', 12500, 9000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'transferencia', NULL, NULL);
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '25% OFF los viernes', 'En toda la carta pagando con crédito Mastercard del Santander.', ARRAY['Viernes']::text[], CURRENT_DATE + 20, 'activa', NULL, NULL, 25)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', 'mastercard', 'Banco Santander');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Empanadas: la docena a precio de 10', 'Llevando una docena, dos van de regalo.', ARRAY['Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', 18000, 15000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'tienda-ramos@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Tienda Ramos', 'tienda-ramos@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/tienda-ramos.svg', 'Indumentaria', 'Ropa urbana para todos los días, hecha en Argentina.', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Scalabrini Ortiz 600, Villa Crespo', -34.5985, -58.4365, '[{"dia":"Lunes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Martes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Miércoles","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Jueves","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Viernes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Sábado","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Domingo","abierto":false,"desde":"10:00","hasta":"20:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '30% OFF en toda la tienda', 'Con cualquier tarjeta de crédito del BBVA.', ARRAY['Jueves', 'Viernes', 'Sábado']::text[], CURRENT_DATE + 2, 'activa', NULL, NULL, 30)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', NULL, 'BBVA');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Segunda remera al 50%', 'Comprando dos remeras, la segunda sale la mitad.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', 36000, 27000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'debito', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'percha-vintage@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Percha Vintage', 'percha-vintage@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/percha-vintage.svg', 'Indumentaria', 'Prendas vintage y de segunda mano seleccionadas una por una.', 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Defensa 900, San Telmo', -34.618, -58.3715, '[{"dia":"Lunes","abierto":false,"desde":"11:00","hasta":"19:00"},{"dia":"Martes","abierto":true,"desde":"11:00","hasta":"19:00"},{"dia":"Miércoles","abierto":true,"desde":"11:00","hasta":"19:00"},{"dia":"Jueves","abierto":true,"desde":"11:00","hasta":"19:00"},{"dia":"Viernes","abierto":true,"desde":"11:00","hasta":"19:00"},{"dia":"Sábado","abierto":true,"desde":"11:00","hasta":"19:00"},{"dia":"Domingo","abierto":true,"desde":"11:00","hasta":"19:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '20% OFF pagando con Ualá', 'En toda la tienda, sin mínimo de compra.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', NULL, NULL, 20)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', 'mastercard', 'Ualá');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Domingos de feria: 10% OFF', 'Descuento en efectivo durante la feria de San Telmo.', ARRAY['Domingo']::text[], NULL, 'activa', NULL, NULL, 10)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'mercado-verde@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Mercado Verde', 'mercado-verde@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/mercado-verde.svg', 'Supermercado', 'Verdulería y almacén con productos frescos de productores locales.', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Rivadavia 5200, Caballito', -34.6185, -58.438, '[{"dia":"Lunes","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Martes","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Miércoles","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Jueves","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Viernes","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Sábado","abierto":true,"desde":"08:00","hasta":"21:00"},{"dia":"Domingo","abierto":true,"desde":"08:00","hasta":"21:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '20% OFF en frutas y verduras', 'Los miércoles con débito Visa del Banco Nación.', ARRAY['Miércoles']::text[], NULL, 'activa', NULL, NULL, 20)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', 'visa', 'Banco Nación');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Bolsón de estación a $8.000', '5 kg de frutas y verduras de estación.', ARRAY['Sábado']::text[], NULL, 'activa', 11000, 8000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'transferencia', NULL, NULL),
      (pro, 'mercadopago', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'super-barrio@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Súper Barrio', 'super-barrio@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/super-barrio.svg', 'Supermercado', 'El súper de cercanía de Flores, abierto todos los días.', 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Rivadavia 7000, Flores', -34.629, -58.463, '[{"dia":"Lunes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Martes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Miércoles","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Jueves","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Viernes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Sábado","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Domingo","abierto":true,"desde":"08:00","hasta":"22:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '25% OFF en todo el súper', 'Con crédito Visa o Mastercard del Banco Ciudad. Tope de reintegro $10.000.', ARRAY['Martes']::text[], NULL, 'activa', NULL, NULL, 25)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', 'visa', 'Banco Ciudad'),
      (pro, 'credito', 'mastercard', 'Banco Ciudad');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '3x2 en lácteos', 'Llevá tres productos lácteos y pagá dos.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', 4500, 3000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'debito', NULL, NULL);
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '15% OFF con Mercado Pago', 'Pagando con QR en las cajas.', ARRAY['Jueves', 'Viernes']::text[], CURRENT_DATE + 1, 'activa', NULL, NULL, 15)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'mercadopago', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'farmacia-cuidarte@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Farmacia Cuidarte', 'farmacia-cuidarte@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/farmacia-cuidarte.svg', 'Farmacia', 'Farmacia y perfumería con atención personalizada.', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Cabildo 1800, Belgrano', -34.5605, -58.4565, '[{"dia":"Lunes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Martes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Miércoles","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Jueves","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Viernes","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Sábado","abierto":true,"desde":"08:00","hasta":"22:00"},{"dia":"Domingo","abierto":true,"desde":"08:00","hasta":"22:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '20% OFF en perfumería', 'Cremas, shampoo y maquillaje con débito del Galicia.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']::text[], NULL, 'activa', NULL, NULL, 20)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', NULL, 'Banco Galicia');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Protector solar 2x1', 'Llevando dos protectores de 200 ml, pagás uno.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', 32000, 16000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'credito', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'farmacia-plaza@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Farmacia Plaza', 'farmacia-plaza@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/farmacia-plaza.svg', 'Farmacia', 'Farmacia de turno las 24 horas en Recoleta.', 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Santa Fe 2100, Recoleta', -34.596, -58.3965, '[{"dia":"Lunes","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Martes","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Miércoles","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Jueves","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Viernes","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Sábado","abierto":true,"desde":"00:00","hasta":"00:00"},{"dia":"Domingo","abierto":true,"desde":"00:00","hasta":"00:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '15% OFF con Brubank', 'En toda la farmacia, todos los días.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', NULL, NULL, 15)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', 'visa', 'Brubank');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Vitaminas: 30% OFF', 'En vitaminas y suplementos seleccionados.', ARRAY['Lunes', 'Martes']::text[], CURRENT_DATE + 10, 'activa', NULL, NULL, 30)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', 'amex', NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'libreria-hojas@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Librería Hojas', 'libreria-hojas@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/libreria-hojas.svg', 'Librería', 'Libros nuevos y usados, café y lectura en un mismo lugar.', 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Callao 1200, Recoleta', -34.5945, -58.393, '[{"dia":"Lunes","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Martes","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Miércoles","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Jueves","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Viernes","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Sábado","abierto":true,"desde":"10:00","hasta":"21:00"},{"dia":"Domingo","abierto":true,"desde":"10:00","hasta":"21:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '20% OFF en novedades', 'En libros recién llegados con crédito del Banco Macro.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', NULL, NULL, 20)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', NULL, 'Banco Macro');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Llevá 3 libros usados por $15.000', 'Elegí tres libros de la mesa de usados.', ARRAY['Sábado', 'Domingo']::text[], NULL, 'activa', 21000, 15000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'transferencia', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'pagina-libre@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Página Libre', 'pagina-libre@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/pagina-libre.svg', 'Librería', 'Librería y papelería escolar para chicos y grandes.', 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Federico Lacroze 3000, Colegiales', -34.576, -58.45, '[{"dia":"Lunes","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Martes","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Miércoles","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Jueves","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Viernes","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Sábado","abierto":true,"desde":"09:00","hasta":"19:00"},{"dia":"Domingo","abierto":false,"desde":"09:00","hasta":"19:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Útiles escolares: 25% OFF', 'Cuadernos, lápices y carpetas con débito del Provincia.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']::text[], NULL, 'activa', NULL, NULL, 25)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', NULL, 'Banco Provincia');
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Agenda 2027 a $9.900', 'Agenda semanal tapa dura.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']::text[], NULL, 'activa', 14000, 9900, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'mercadopago', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'electrohogar-nunez@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('ElectroHogar Núñez', 'electrohogar-nunez@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/electrohogar-nunez.svg', 'Electrodomésticos', 'Lavarropas, heladeras y pequeños electrodomésticos con envío en el día.', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Cabildo 3200, Núñez', -34.549, -58.464, '[{"dia":"Lunes","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Martes","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Miércoles","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Jueves","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Viernes","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Sábado","abierto":true,"desde":"09:00","hasta":"20:00"},{"dia":"Domingo","abierto":false,"desde":"09:00","hasta":"20:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Lavarropas 8 kg a $650.000', 'Carga frontal, con instalación incluida.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']::text[], NULL, 'activa', 820000, 650000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', 'visa', NULL),
      (pro, 'credito', 'mastercard', NULL);
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '10% OFF en efectivo', 'En todos los productos, pagando en efectivo o transferencia.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']::text[], NULL, 'activa', NULL, NULL, 10)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'efectivo', NULL, NULL),
      (pro, 'transferencia', NULL, NULL);
  END IF;
END $datos$;

DO $datos$
DECLARE emp int; suc int; pro int;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE mail = 'tecno-punto@prueba.sumatoria.com') THEN
    INSERT INTO empresa (nombre, mail, "contraseña", logo, rubro, descripcion, portada)
    VALUES ('Tecno Punto', 'tecno-punto@prueba.sumatoria.com', '$2b$10$8HWytU6FhT3JMeqBNqlsDeF/h5vps99MQNBTEmFMTRPTKtzoM31Ji', '/logos/prueba/tecno-punto.svg', 'Electrodomésticos', 'Tecnología, auriculares y accesorios para tu casa y tu trabajo.', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=1200&q=70&auto=format&fit=crop')
    RETURNING id_empresa INTO emp;
    INSERT INTO sucursal (id_empresa, direccion, lat, lng, horarios)
    VALUES (emp, 'Av. Pueyrredón 400, Balvanera', -34.607, -58.4055, '[{"dia":"Lunes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Martes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Miércoles","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Jueves","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Viernes","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Sábado","abierto":true,"desde":"10:00","hasta":"20:00"},{"dia":"Domingo","abierto":false,"desde":"10:00","hasta":"20:00"}]'::jsonb)
    RETURNING id_sucursal INTO suc;
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, 'Auriculares bluetooth a $35.000', 'Auriculares inalámbricos con cancelación de ruido.', ARRAY['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']::text[], NULL, 'activa', 52000, 35000, NULL)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'debito', NULL, NULL),
      (pro, 'mercadopago', NULL, NULL);
    INSERT INTO descuentos_sucursal (id_sucursal, titulo, descripcion, dias, vence, estado, precio_real, precio_promo, porcentaje)
    VALUES (suc, '20% OFF en accesorios', 'Cargadores, fundas y cables con crédito del ICBC.', ARRAY['Viernes', 'Sábado']::text[], CURRENT_DATE + 15, 'activa', NULL, NULL, 20)
    RETURNING id_descuento INTO pro;
    INSERT INTO aplican (id_descuento, tipo, red_pago, emisor) VALUES
      (pro, 'credito', NULL, 'ICBC');
  END IF;
END $datos$;

COMMIT;
