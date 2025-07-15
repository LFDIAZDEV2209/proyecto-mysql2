-- INSERCIONES PARA PROYECTO MYSQL2
-- Datos para probar todas las consultas SQL especializadas

-- 1. COUNTRIES
INSERT INTO countries (isocode, name, alfasitwo, alfasitothree) VALUES
('169', 'Colombia', 'CO', 'COL'),
('493', 'México', 'MX', 'MEX'),
('063', 'Argentina', 'AR', 'ARG'),
('105', 'Brasil', 'BR', 'BRA'),
('211', 'Chile', 'CL', 'CHL');

-- 2. SUBDIVISIONCATEGORIES
INSERT INTO subdivisioncategories (id, description) VALUES
(1, 'Departamento'),
(2, 'Estado'),
(3, 'Provincia'),
(4, 'Región');

-- 3. STATEREGIONS
INSERT INTO stateregions (code, name, country_id, code3166, subdivision_id) VALUES
('CO-ANT', 'Antioquia', '169', 'CO-ANT', 1),
('CO-CUN', 'Cundinamarca', '169', 'CO-CUN', 1),
('CO-VAL', 'Valle del Cauca', '169', 'CO-VAC', 1),
('MX-JAL', 'Jalisco', '493', 'MX-JAL', 2),
('MX-DF', 'Distrito Federal', '493', 'MX-CMX', 2),
('AR-BUE', 'Buenos Aires', '063', 'AR-BUE', 3),
('BR-SP', 'São Paulo', '105', 'BR-SP', 2),
('CL-RM', 'Región Metropolitana', '211', 'CL-RM', 4);

-- 4. CITIESORMUNICIPALITIES
INSERT INTO citiesormunicipalities (code, name, statereg_id) VALUES
('05001', 'Medellín', 'CO-ANT'),
('11001', 'Bogotá D.C.', 'CO-CUN'),
('76001', 'Cali', 'CO-VAL'),
('14039', 'Guadalajara', 'MX-JAL'),
('09002', 'Ciudad de México', 'MX-DF'),
('06001', 'Buenos Aires', 'AR-BUE'),
('35503', 'São Paulo', 'BR-SP'),
('13101', 'Santiago', 'CL-RM'),
('08001', 'Barranquilla', 'CO-ANT'),
('17001', 'Manizales', 'CO-CUN');

-- 5. TYPESOFIDENTIFICATIONS
INSERT INTO typesofidentifications (id, description, suffix) VALUES
(1, 'Cédula de Ciudadanía', 'CC'),
(2, 'NIT', 'NIT'),
(3, 'Cédula de Extranjería', 'CE'),
(4, 'Pasaporte', 'PP'),
(5, 'Tarjeta de Identidad', 'TI');

-- 6. UNITOFMEASURE
INSERT INTO unitofmeasure (id, description) VALUES
(1, 'Unidad'),
(2, 'Kilogramo'),
(3, 'Litro'),
(4, 'Metro'),
(5, 'Hora'),
(6, 'Servicio'),
(7, 'Paquete'),
(8, 'Caja'),
(9, 'Docena'),
(10, 'Metro Cuadrado');

-- 7. CATEGORIES
INSERT INTO categories (id, description) VALUES
(1, 'Tecnología'),
(2, 'Alimentos'),
(3, 'Servicios'),
(4, 'Construcción'),
(5, 'Salud'),
(6, 'Educación'),
(7, 'Transporte'),
(8, 'Entretenimiento'),
(9, 'Moda'),
(10, 'Hogar');

-- 8. AUDIENCES
INSERT INTO audiences (id, description) VALUES
(1, 'Empresas'),
(2, 'Consumidores Finales'),
(3, 'Gobierno'),
(4, 'Instituciones Educativas'),
(5, 'Sector Salud'),
(6, 'Sector Financiero'),
(7, 'Sector Turístico'),
(8, 'Sector Agrícola');

-- 9. COMPANIES
INSERT INTO companies (id, type_id, name, category_id, city_id, audience_id, cellphone, email) VALUES
('COMP001', 2, 'TechSolutions SA', 1, '05001', 1, '5743001234567', 'info@techsolutions.com'),
('COMP002', 2, 'Alimentos Frescos Ltda', 2, '11001', 2, '5713002345678', 'ventas@alimentosfrescos.com'),
('COMP003', 2, 'Servicios Integrales', 3, '76001', 1, '5723003456789', 'contacto@serviciosintegrales.com'),
('COMP004', 2, 'Construcciones Modernas', 4, '14039', 1, '5233004567890', 'info@construccionesmodernas.com'),
('COMP005', 2, 'Clínica Salud Total', 5, '09002', 5, '5253005678901', 'citas@saludtotal.com'),
('COMP006', 2, 'Academia Digital', 6, '06001', 4, '54113006789012', 'info@academiadigital.com'),
('COMP007', 2, 'Transporte Rápido', 7, '35503', 2, '55113007890123', 'reservas@transportepido.com'),
('COMP008', 2, 'Entretenimiento Plus', 8, '13101', 2, '5623008901234', 'ventas@entretenimientoplus.com'),
('COMP009', 2, 'Moda Elegante', 9, '08001', 2, '5753009012345', 'ventas@modaelegante.com'),
('COMP010', 2, 'Hogar y Jardín', 10, '17001', 2, '5763000123456', 'info@hogaryjardin.com'),
('COMP011', 2, 'Software Avanzado', 1, '05001', 1, '5743001234568', 'ventas@softwareavanzado.com'),
('COMP012', 2, 'Restaurante Gourmet', 2, '11001', 2, '5713002345679', 'reservas@restaurantegourmet.com'),
('COMP013', 2, 'Consultoría Empresarial', 3, '76001', 1, '5723003456790', 'contacto@consultoriaempresarial.com'),
('COMP014', 2, 'Sin Productos SA', 1, '05001', 1, '5743004567891', 'info@sinproductos.com'),
('COMP015', 2, 'Empresa Sin Calificaciones', 2, '11001', 2, '5713005678902', 'info@empresasincalificaciones.com');

-- 10. CUSTOMERS
INSERT INTO customers (name, city_id, audience_id, cellphone, email, address) VALUES
('Juan Pérez', '05001', 2, '5743101234567', 'juan.perez@email.com', 'Calle 123 #45-67'),
('María García', '11001', 2, '5713102345678', 'maria.garcia@email.com', 'Carrera 78 #12-34'),
('Carlos López', '76001', 2, '5723103456789', 'carlos.lopez@email.com', 'Avenida 5 #23-45'),
('Ana Rodríguez', '14039', 2, '5233104567890', 'ana.rodriguez@email.com', 'Calle Principal #67-89'),
('Luis Martínez', '09002', 2, '5253105678901', 'luis.martinez@email.com', 'Avenida Central #34-56'),
('Carmen Silva', '06001', 2, '54113106789012', 'carmen.silva@email.com', 'Calle Mayor #78-90'),
('Roberto Torres', '35503', 2, '55113107890123', 'roberto.torres@email.com', 'Rua Principal #12-34'),
('Patricia Vargas', '13101', 2, '5623108901234', 'patricia.vargas@email.com', 'Avenida Libertador #45-67'),
('Fernando Ruiz', '08001', 2, '5753109012345', 'fernando.ruiz@email.com', 'Calle del Comercio #89-12'),
('Isabel Morales', '17001', 2, '5763100123456', 'isabel.morales@email.com', 'Carrera 15 #23-45'),
('Diego Herrera', '05001', 2, '5743101234568', 'diego.herrera@email.com', 'Calle 45 #67-89'),
('Sofia Jiménez', '11001', 2, '5713102345679', 'sofia.jimenez@email.com', 'Carrera 90 #12-34'),
('Andrés Castro', '76001', 2, '5723103456790', 'andres.castro@email.com', 'Avenida 8 #45-67'),
('Valentina Rojas', '14039', 2, '5233104567891', 'valentina.rojas@email.com', 'Calle Secundaria #78-90'),
('Miguel Ángel', '09002', 2, '5253105678902', 'miguel.angel@email.com', 'Avenida Norte #23-45');

-- 11. PRODUCTS
INSERT INTO products (name, detail, price, category_id, image) VALUES
('Laptop Pro', 'Laptop de alta gama para profesionales', 2500000.00, 1, 'laptop_pro.jpg'),
('Smartphone Galaxy', 'Teléfono inteligente con cámara avanzada', 1200000.00, 1, 'smartphone_galaxy.jpg'),
('Arroz Integral', 'Arroz integral orgánico 1kg', 8500.00, 2, 'arroz_integral.jpg'),
('Leche Deslactosada', 'Leche deslactosada 1L', 3500.00, 2, 'leche_deslactosada.jpg'),
('Servicio de Limpieza', 'Servicio de limpieza residencial', 150000.00, 3, 'servicio_limpieza.jpg'),
('Consultoría IT', 'Servicio de consultoría en tecnología', 500000.00, 3, 'consultoria_it.jpg'),
('Cemento Portland', 'Cemento Portland 50kg', 25000.00, 4, 'cemento_portland.jpg'),
('Ladrillos', 'Ladrillos de arcilla 100 unidades', 45000.00, 4, 'ladrillos.jpg'),
('Consulta Médica', 'Consulta médica general', 80000.00, 5, 'consulta_medica.jpg'),
('Examen de Sangre', 'Examen de sangre completo', 120000.00, 5, 'examen_sangre.jpg'),
('Curso de Programación', 'Curso online de programación', 500000.00, 6, 'curso_programacion.jpg'),
('Libro de Matemáticas', 'Libro de matemáticas avanzadas', 45000.00, 6, 'libro_matematicas.jpg'),
('Servicio de Taxi', 'Servicio de taxi por hora', 25000.00, 7, 'servicio_taxi.jpg'),
('Alquiler de Carro', 'Alquiler de carro por día', 150000.00, 7, 'alquiler_carro.jpg'),
('Entrada Cine', 'Entrada para película', 25000.00, 8, 'entrada_cine.jpg'),
('Concierto Rock', 'Entrada para concierto de rock', 150000.00, 8, 'concierto_rock.jpg'),
('Camisa Formal', 'Camisa formal de algodón', 85000.00, 9, 'camisa_formal.jpg'),
('Zapatos Deportivos', 'Zapatos deportivos running', 180000.00, 9, 'zapatos_deportivos.jpg'),
('Sofá 3 Plazas', 'Sofá de 3 plazas moderno', 1200000.00, 10, 'sofa_3_plazas.jpg'),
('Mesa de Comedor', 'Mesa de comedor para 6 personas', 800000.00, 10, 'mesa_comedor.jpg'),
('Producto Sin Medida', 'Producto sin unidad de medida', 50000.00, 1, 'producto_sin_medida.jpg'),
('Producto Duplicado A', 'Producto con nombre duplicado versión A', 75000.00, 2, 'producto_duplicado_a.jpg'),
('Producto Duplicado B', 'Producto con nombre duplicado versión B', 75000.00, 2, 'producto_duplicado_b.jpg'),
('Laptop Pro Duplicado', 'Laptop duplicada', 2500000.00, 1, 'laptop_duplicada.jpg');

-- 12. COMPANYPRODUCTS
INSERT INTO companyproducts (company_id, product_id, price, unitmeasure_id) VALUES
-- TechSolutions SA
('COMP001', 24, 2500000.00, 1),
('COMP001', 25, 1200000.00, 1),
('COMP001', 29, 500000.00, 5),
-- Alimentos Frescos Ltda
('COMP002', 26, 8500.00, 2),
('COMP002', 27, 3500.00, 3),
-- Servicios Integrales
('COMP003', 28, 150000.00, 6),
('COMP003', 29, 500000.00, 5),
-- Construcciones Modernas
('COMP004', 30, 25000.00, 2),
('COMP004', 31, 45000.00, 7),
-- Clínica Salud Total
('COMP005', 32, 80000.00, 6),
('COMP005', 33, 120000.00, 6),
-- Academia Digital
('COMP006', 34, 500000.00, 5),
('COMP006', 35, 45000.00, 1),
-- Transporte Rápido
('COMP007', 36, 25000.00, 5),
('COMP007', 37, 150000.00, 5),
-- Entretenimiento Plus
('COMP008', 38, 25000.00, 1),
('COMP008', 39, 150000.00, 1),
-- Moda Elegante
('COMP009', 40, 85000.00, 1),
('COMP009', 41, 180000.00, 1),
-- Hogar y Jardín
('COMP010', 42, 1200000.00, 1),
('COMP010', 43, 800000.00, 1),
-- Software Avanzado
('COMP011', 24, 2400000.00, 1),
('COMP011', 25, 1180000.00, 1),
-- Restaurante Gourmet
('COMP012', 26, 9000.00, 2),
('COMP012', 27, 3800.00, 3),
-- Consultoría Empresarial
('COMP013', 28, 160000.00, 6),
('COMP013', 29, 520000.00, 5),
-- Productos sin medida
('COMP001', 44, 50000.00, NULL),
('COMP002', 45, 75000.00, 1),
('COMP003', 46, 75000.00, 1),
-- Agregar a companyproducts para que la misma empresa tenga ambos
('COMP001', 47, 2500000.00, 1);  -- Mismo producto "Laptop Pro" en COMP001

-- 13. FAVORITES
INSERT INTO favorites (customer_id, company_id) VALUES
(1, 'COMP001'),
(1, 'COMP002'),
(2, 'COMP001'),
(2, 'COMP003'),
(3, 'COMP002'),
(3, 'COMP004'),
(4, 'COMP001'),
(4, 'COMP005'),
(5, 'COMP002'),
(5, 'COMP006'),
(6, 'COMP001'),
(6, 'COMP007'),
(7, 'COMP002'),
(7, 'COMP008'),
(8, 'COMP001'),
(8, 'COMP009'),
(9, 'COMP002'),
(9, 'COMP010'),
(10, 'COMP001'),
(10, 'COMP011'),
(11, 'COMP002'),
(11, 'COMP012'),
(12, 'COMP001'),
(12, 'COMP013'),
(13, 'COMP002'),
(14, 'COMP001'),
(15, 'COMP002');

-- 14. DETAILS_FAVORITES
INSERT INTO details_favorites (id, favorite_id, product_id) VALUES
(1, 1, 24),
(2, 1, 25),
(3, 2, 26),
(4, 2, 27),
(5, 3, 24),
(6, 3, 29),
(7, 4, 30),
(8, 4, 31),
(9, 5, 32),
(10, 5, 33),
(11, 6, 34),
(12, 6, 35),
(13, 7, 36),
(14, 7, 37),
(15, 8, 38),
(16, 8, 39),
(17, 9, 40),
(18, 9, 41),
(19, 10, 42),
(20, 10, 43),
(21, 11, 24),
(22, 11, 25),
(23, 12, 26),
(24, 12, 27),
(25, 13, 28),
(26, 13, 29),
(27, 14, 30),
(28, 14, 31),
(29, 15, 32),
(30, 15, 33),
(31, 16, 34),
(32, 16, 35),
(33, 17, 36),
(34, 17, 37),
(35, 18, 38),
(36, 18, 39),
(37, 19, 40),
(38, 19, 41),
(39, 20, 42),
(40, 20, 43),
(41, 21, 24),
(42, 21, 25),
(43, 22, 26),
(44, 22, 27),
(45, 23, 24),
(46, 23, 29),
(47, 24, 28),
(48, 24, 29),
(49, 25, 26),
(50, 25, 27),
(51, 26, 24),
(52, 27, 26),
(53, 27, 26),
-- Productos favoritos sin calificar (nuevos)
(54, 1, 44),
(55, 2, 45),
(56, 3, 46),
(57, 4, 44),
(58, 5, 45),
(59, 6, 46),
(60, 7, 44),
(61, 8, 45),
(62, 9, 46),
(63, 10, 44);

-- 15. POLLS
INSERT INTO polls (name, description, isactive, categorypoll_id) VALUES
('Satisfacción General', 'Encuesta de satisfacción general del cliente', 1, 1),
('Calidad de Producto', 'Evaluación de la calidad de productos', 1, 2),
('Servicio al Cliente', 'Evaluación del servicio al cliente', 1, 3),
('Precios', 'Evaluación de precios y relación calidad-precio', 1, 2),
('Entrega', 'Evaluación del servicio de entrega', 1, 7),
('Satisfacción Tecnología', 'Encuesta específica para productos tecnológicos', 1, 1),
('Calidad Alimentaria', 'Evaluación de productos alimenticios', 1, 2),
('Servicios Profesionales', 'Evaluación de servicios profesionales', 1, 3);

-- 16. QUALITY_PRODUCTS
INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating) VALUES
-- Calificaciones recientes (últimos 6 meses)
(24, 1, 1, 'COMP001', '2024-01-15 10:30:00', 4.5),
(25, 1, 1, 'COMP001', '2024-01-16 14:20:00', 4.8),
(26, 2, 2, 'COMP002', '2024-01-17 09:15:00', 4.2),
(27, 2, 2, 'COMP002', '2024-01-18 16:45:00', 4.6),
(28, 3, 3, 'COMP003', '2024-01-19 11:30:00', 4.0),
(29, 3, 3, 'COMP003', '2024-01-20 13:20:00', 4.7),
(30, 4, 4, 'COMP004', '2024-01-21 08:45:00', 3.8),
(31, 4, 4, 'COMP004', '2024-01-22 15:10:00', 4.3),
(32, 5, 5, 'COMP005', '2024-01-23 12:00:00', 4.9),
(33, 5, 5, 'COMP005', '2024-01-24 17:30:00', 4.4),
(34, 6, 6, 'COMP006', '2024-01-25 10:15:00', 4.6),
(35, 6, 6, 'COMP006', '2024-01-26 14:40:00', 4.1),
(36, 7, 7, 'COMP007', '2024-01-27 09:30:00', 3.9),
(37, 7, 7, 'COMP007', '2024-01-28 16:20:00', 4.5),
(38, 8, 8, 'COMP008', '2024-01-29 11:45:00', 4.7),
(39, 8, 8, 'COMP008', '2024-01-30 13:15:00', 4.2),
(40, 9, 1, 'COMP009', '2024-02-01 08:30:00', 4.3),
(41, 9, 1, 'COMP009', '2024-02-02 15:45:00', 4.8),
(42, 10, 2, 'COMP010', '2024-02-03 12:20:00', 4.1),
(43, 10, 2, 'COMP010', '2024-02-04 17:10:00', 4.6),
-- Más calificaciones para tener datos variados
(24, 11, 1, 'COMP001', '2024-02-05 10:00:00', 4.7),
(25, 11, 1, 'COMP001', '2024-02-06 14:30:00', 4.4),
(26, 12, 2, 'COMP002', '2024-02-07 09:45:00', 4.3),
(27, 12, 2, 'COMP002', '2024-02-08 16:00:00', 4.5),
(28, 13, 3, 'COMP003', '2024-02-09 11:15:00', 4.2),
(29, 13, 3, 'COMP003', '2024-02-10 13:50:00', 4.8),
(30, 14, 4, 'COMP004', '2024-02-11 08:20:00', 3.9),
(31, 14, 4, 'COMP004', '2024-02-12 15:35:00', 4.4),
(32, 15, 5, 'COMP005', '2024-02-13 12:10:00', 4.6),
(33, 15, 5, 'COMP005', '2024-02-14 17:25:00', 4.3);

-- 17. RATES
INSERT INTO rates (customer_id, company_id, poll_id, daterating, rating) VALUES
(1, 'COMP001', 1, '2024-01-15 10:30:00', 4.5),
(2, 'COMP002', 2, '2024-01-17 09:15:00', 4.2),
(3, 'COMP003', 3, '2024-01-19 11:30:00', 4.0),
(4, 'COMP004', 4, '2024-01-21 08:45:00', 3.8),
(5, 'COMP005', 5, '2024-01-23 12:00:00', 4.9),
(6, 'COMP006', 6, '2024-01-25 10:15:00', 4.6),
(7, 'COMP007', 7, '2024-01-27 09:30:00', 3.9),
(8, 'COMP008', 8, '2024-01-29 11:45:00', 4.7),
(9, 'COMP009', 1, '2024-02-01 08:30:00', 4.3),
(10, 'COMP010', 2, '2024-02-03 12:20:00', 4.1),
(11, 'COMP001', 1, '2024-02-05 10:00:00', 4.7),
(12, 'COMP002', 2, '2024-02-07 09:45:00', 4.3),
(13, 'COMP003', 3, '2024-02-09 11:15:00', 4.2),
(14, 'COMP004', 4, '2024-02-11 08:20:00', 3.9),
(15, 'COMP005', 5, '2024-02-13 12:10:00', 4.6);

-- 18. MEMBERSHIPS
INSERT INTO memberships (name, description) VALUES
('Básico', 'Plan básico con beneficios limitados'),
('Premium', 'Plan premium con beneficios completos'),
('Empresarial', 'Plan especializado para empresas'),
('Estudiante', 'Plan con descuentos para estudiantes'),
('VIP', 'Plan VIP con beneficios exclusivos'),
('Sin Beneficios', 'Plan sin beneficios registrados');

-- 19. PERIODS
INSERT INTO periods (name) VALUES
('Mensual'),
('Trimestral'),
('Semestral'),
('Anual'),
('Bienal');

-- 20. MEMBERSHIPPERIODS
INSERT INTO membershipperiods (membership_id, period_id, price) VALUES
(1, 1, 50000.00),
(1, 2, 140000.00),
(1, 3, 270000.00),
(1, 4, 500000.00),
(2, 1, 100000.00),
(2, 2, 280000.00),
(2, 3, 540000.00),
(2, 4, 1000000.00),
(3, 1, 150000.00),
(3, 2, 420000.00),
(3, 3, 810000.00),
(3, 4, 1500000.00),
(4, 1, 30000.00),
(4, 2, 84000.00),
(4, 3, 162000.00),
(4, 4, 300000.00),
(5, 1, 200000.00),
(5, 2, 560000.00),
(5, 3, 1080000.00),
(5, 4, 2000000.00),
(6, 1, 25000.00),
(6, 2, 70000.00),
(6, 3, 135000.00),
(6, 4, 250000.00);

-- 21. BENEFITS
INSERT INTO benefits (description, detail) VALUES
('Descuento 10%', 'Descuento del 10% en todos los productos'),
('Envío Gratis', 'Envío gratuito en todas las compras'),
('Soporte Prioritario', 'Soporte técnico prioritario 24/7'),
('Acceso Exclusivo', 'Acceso a productos y servicios exclusivos'),
('Capacitación', 'Capacitación gratuita en productos'),
('Garantía Extendida', 'Garantía extendida por 2 años'),
('Consultoría Gratuita', 'Sesión de consultoría gratuita mensual'),
('Descuento 20%', 'Descuento del 20% en productos seleccionados'),
('Membresía VIP', 'Acceso a eventos exclusivos y descuentos especiales'),
('Soporte Empresarial', 'Soporte especializado para empresas');

-- 22. MEMBERSHIPBENEFITS
INSERT INTO membershipbenefits (membership_id, period_id, audience_id, benefit_id) VALUES
(1, 1, 2, 1),
(1, 1, 2, 2),
(1, 2, 2, 1),
(1, 2, 2, 2),
(1, 2, 2, 3),
(2, 1, 2, 1),
(2, 1, 2, 2),
(2, 1, 2, 3),
(2, 1, 2, 4),
(2, 2, 2, 1),
(2, 2, 2, 2),
(2, 2, 2, 3),
(2, 2, 2, 4),
(2, 2, 2, 5),
(3, 1, 1, 1),
(3, 1, 1, 3),
(3, 1, 1, 7),
(3, 1, 1, 10),
(3, 2, 1, 1),
(3, 2, 1, 3),
(3, 2, 1, 7),
(3, 2, 1, 10),
(3, 2, 1, 5),
(4, 1, 4, 1),
(4, 1, 4, 2),
(4, 1, 4, 5),
(4, 2, 4, 1),
(4, 2, 4, 2),
(4, 2, 4, 5),
(4, 2, 4, 3),
(5, 1, 2, 1),
(5, 1, 2, 2),
(5, 1, 2, 3),
(5, 1, 2, 4),
(5, 1, 2, 5),
(5, 1, 2, 6),
(5, 1, 2, 9),
(5, 2, 2, 1),
(5, 2, 2, 2),
(5, 2, 2, 3),
(5, 2, 2, 4),
(5, 2, 2, 5),
(5, 2, 2, 6),
(5, 2, 2, 9),
(5, 2, 2, 7),
(5, 2, 2, 8);

-- 23. AUDIENCEBENEFITS
INSERT INTO audiencebenefits (audience_id, benefit_id) VALUES
(1, 1),
(1, 3),
(1, 7),
(1, 10),
(2, 1),
(2, 2),
(2, 4),
(2, 9),
(3, 1),
(3, 3),
(3, 7),
(4, 1),
(4, 2),
(4, 5),
(5, 1),
(5, 3),
(5, 6),
(6, 1),
(6, 3),
(6, 7),
(7, 1),
(7, 2),
(7, 4),
(8, 1),
(8, 3),
(8, 5);

-- 24. CATEGORIES_POLLS
INSERT INTO categories_polls (name) VALUES
('Satisfacción General'),
('Calidad de Producto'),
('Servicio al Cliente'),
('Precios'),
('Entrega'),
('Tecnología'),
('Alimentación'),
('Servicios Profesionales');

-- 25. CUSTOMER_MEMBERSHIPS
INSERT INTO customer_memberships (customer_id, membership_id, start_date, end_date, isactive) VALUES
-- Clientes con membresías activas
(1, 1, '2024-01-01', '2024-12-31', 1),  -- Juan Pérez - Básico
(2, 2, '2024-01-15', '2024-12-31', 1),  -- María García - Premium
(3, 3, '2024-02-01', '2024-12-31', 1),  -- Carlos López - Empresarial
(4, 4, '2024-01-10', '2024-06-30', 1),  -- Ana Rodríguez - Estudiante
(5, 5, '2024-01-20', '2024-12-31', 1),  -- Luis Martínez - VIP
(6, 1, '2024-02-01', '2024-12-31', 1),  -- Carmen Silva - Básico
(7, 2, '2024-01-05', '2024-12-31', 1),  -- Roberto Torres - Premium
(8, 3, '2024-01-25', '2024-12-31', 1),  -- Patricia Vargas - Empresarial
(9, 4, '2024-02-15', '2024-08-31', 1),  -- Fernando Ruiz - Estudiante
(10, 5, '2024-01-30', '2024-12-31', 1), -- Isabel Morales - VIP

-- Clientes con membresías inactivas o vencidas
(11, 1, '2023-01-01', '2023-12-31', 0), -- Diego Herrera - Básico (vencida)
(12, 2, '2023-06-01', '2023-12-31', 0), -- Sofia Jiménez - Premium (vencida)
(13, 3, '2023-03-01', '2023-12-31', 0); -- Andrés Castro - Empresarial (vencida)

-- Clientes sin membresías (no incluidos en esta tabla)
-- Clientes 14 y 15 no tienen membresías registradas
