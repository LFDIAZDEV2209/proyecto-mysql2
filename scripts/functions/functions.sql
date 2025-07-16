-- Funciones Definidas por el Usuario (UDF)

-- 1. Calcular promedio ponderado de calidad de un producto
DELIMITER //
CREATE FUNCTION calcular_promedio_ponderado(product_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE promedio_ponderado DECIMAL(5,2);
    
    SELECT ROUND(
        SUM(qp.rating * (1 + DATEDIFF(CURDATE(), DATE(qp.daterating)) / 365)) / 
        SUM(1 + DATEDIFF(CURDATE(), DATE(qp.daterating)) / 365), 2
    ) INTO promedio_ponderado
    FROM quality_products qp
    WHERE qp.product_id = product_id;
    
    RETURN IFNULL(promedio_ponderado, 0);
END //
DELIMITER ;

-- 2. Determinar si un producto ha sido calificado recientemente
DELIMITER //
CREATE FUNCTION es_calificacion_reciente(fecha DATETIME)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(CURDATE(), DATE(fecha)) <= 30;
END //
DELIMITER ;

-- 3. Obtener nombre completo de la empresa que vende un producto
DELIMITER //
CREATE FUNCTION obtener_empresa_producto(product_id INT)
RETURNS VARCHAR(80)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE nombre_empresa VARCHAR(80);
    
    SELECT c.name INTO nombre_empresa
    FROM companyproducts cp
    INNER JOIN companies c ON cp.company_id = c.id
    WHERE cp.product_id = product_id
    LIMIT 1;
    
    RETURN IFNULL(nombre_empresa, 'Sin empresa asignada');
END //
DELIMITER ;

-- 4. Verificar si un cliente tiene membresía activa
DELIMITER //
CREATE FUNCTION tiene_membresia_activa(customer_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE membresia_activa BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS(
        SELECT 1 FROM customer_memberships cm
        WHERE cm.customer_id = customer_id
        AND cm.isactive = 1
        AND CURDATE() BETWEEN cm.start_date AND cm.end_date
    ) INTO membresia_activa;
    
    RETURN membresia_activa;
END //
DELIMITER ;

-- 5. Validar si una ciudad tiene más de X empresas registradas
DELIMITER //
CREATE FUNCTION ciudad_supera_empresas(city_id VARCHAR(6), limite INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cantidad_empresas INT;
    
    SELECT COUNT(*) INTO cantidad_empresas
    FROM companies c
    WHERE c.city_id = city_id;
    
    RETURN cantidad_empresas > limite;
END //
DELIMITER ;

-- 6. Devolver descripción textual de una calificación
DELIMITER //
CREATE FUNCTION descripcion_calificacion(valor DECIMAL(3,2))
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE descripcion VARCHAR(20);
    
    CASE 
        WHEN valor >= 4.5 THEN SET descripcion = 'Excelente';
        WHEN valor >= 4.0 THEN SET descripcion = 'Muy bueno';
        WHEN valor >= 3.5 THEN SET descripcion = 'Bueno';
        WHEN valor >= 3.0 THEN SET descripcion = 'Regular';
        WHEN valor >= 2.0 THEN SET descripcion = 'Malo';
        ELSE SET descripcion = 'Muy malo';
    END CASE;
    
    RETURN descripcion;
END //
DELIMITER ;

-- 7. Determinar estado de un producto según su evaluación
DELIMITER //
CREATE FUNCTION estado_producto(product_id INT)
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE promedio_calificacion DECIMAL(5,2);
    DECLARE estado VARCHAR(20);
    
    SELECT AVG(qp.rating) INTO promedio_calificacion
    FROM quality_products qp
    WHERE qp.product_id = product_id;
    
    IF promedio_calificacion IS NULL THEN
        SET estado = 'Sin evaluar';
    ELSEIF promedio_calificacion >= 4.0 THEN
        SET estado = 'Óptimo';
    ELSEIF promedio_calificacion >= 3.0 THEN
        SET estado = 'Aceptable';
    ELSE
        SET estado = 'Crítico';
    END IF;
    
    RETURN estado;
END //
DELIMITER ;

-- 8. Verificar si un producto está en favoritos de un cliente
DELIMITER //
CREATE FUNCTION es_favorito(customer_id INT, product_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE es_fav BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS(
        SELECT 1 FROM favorites f
        INNER JOIN details_favorites df ON f.id = df.favorite_id
        WHERE f.customer_id = customer_id AND df.product_id = product_id
    ) INTO es_fav;
    
    RETURN es_fav;
END //
DELIMITER ;

-- 9. Verificar si un beneficio está asignado a una audiencia específica
DELIMITER //
CREATE FUNCTION beneficio_asignado_audiencia(benefit_id INT, audience_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE asignado BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS(
        SELECT 1 FROM audiencebenefits ab
        WHERE ab.benefit_id = benefit_id AND ab.audience_id = audience_id
    ) INTO asignado;
    
    RETURN asignado;
END //
DELIMITER ;

-- 10. Verificar si una fecha está dentro de un rango de membresía activa
DELIMITER //
CREATE FUNCTION fecha_en_membresia(fecha DATE, customer_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE en_membresia BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS(
        SELECT 1 FROM customer_memberships cm
        WHERE cm.customer_id = customer_id
        AND cm.isactive = 1
        AND fecha BETWEEN cm.start_date AND cm.end_date
    ) INTO en_membresia;
    
    RETURN en_membresia;
END //
DELIMITER ;

-- 11. Calcular porcentaje de calificaciones positivas de un producto
DELIMITER //
CREATE FUNCTION porcentaje_positivas(product_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE porcentaje DECIMAL(5,2);
    DECLARE total_calificaciones INT;
    DECLARE calificaciones_positivas INT;
    
    SELECT COUNT(*) INTO total_calificaciones
    FROM quality_products qp
    WHERE qp.product_id = product_id;
    
    SELECT COUNT(*) INTO calificaciones_positivas
    FROM quality_products qp
    WHERE qp.product_id = product_id AND qp.rating >= 4.0;
    
    IF total_calificaciones = 0 THEN
        SET porcentaje = 0;
    ELSE
        SET porcentaje = ROUND((calificaciones_positivas * 100.0) / total_calificaciones, 2);
    END IF;
    
    RETURN porcentaje;
END //
DELIMITER ;

-- 12. Calcular la edad de una calificación en días
DELIMITER //
CREATE FUNCTION edad_calificacion(fecha_calificacion DATETIME)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(CURDATE(), DATE(fecha_calificacion));
END //
DELIMITER ;

-- 13. Contar productos únicos por empresa
DELIMITER //
CREATE FUNCTION productos_por_empresa(company_id VARCHAR(20))
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cantidad_productos INT;
    
    SELECT COUNT(DISTINCT cp.product_id) INTO cantidad_productos
    FROM companyproducts cp
    WHERE cp.company_id = company_id;
    
    RETURN cantidad_productos;
END //
DELIMITER ;

-- 14. Determinar nivel de actividad de un cliente
DELIMITER //
CREATE FUNCTION nivel_actividad_cliente(customer_id INT)
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cantidad_calificaciones INT;
    DECLARE nivel VARCHAR(20);
    
    SELECT COUNT(*) INTO cantidad_calificaciones
    FROM quality_products qp
    WHERE qp.customer_id = customer_id;
    
    IF cantidad_calificaciones >= 10 THEN
        SET nivel = 'Frecuente';
    ELSEIF cantidad_calificaciones >= 3 THEN
        SET nivel = 'Esporádico';
    ELSE
        SET nivel = 'Inactivo';
    END IF;
    
    RETURN nivel;
END //
DELIMITER ;

-- 15. Calcular precio promedio ponderado de un producto
DELIMITER //
CREATE FUNCTION precio_promedio_ponderado(product_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE precio_promedio DECIMAL(10,2);
    
    SELECT ROUND(
        SUM(cp.price * (SELECT COUNT(*) FROM details_favorites df 
                       INNER JOIN favorites f ON df.favorite_id = f.id 
                       WHERE df.product_id = product_id)) / 
        COUNT(*), 2
    ) INTO precio_promedio
    FROM companyproducts cp
    WHERE cp.product_id = product_id;
    
    RETURN IFNULL(precio_promedio, 0);
END //
DELIMITER ;

-- 16. Verificar si un beneficio está asignado a múltiples audiencias o membresías
DELIMITER //
CREATE FUNCTION beneficio_multiple_asignacion(benefit_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE asignaciones_audiencia INT;
    DECLARE asignaciones_membresia INT;
    
    SELECT COUNT(*) INTO asignaciones_audiencia
    FROM audiencebenefits ab
    WHERE ab.benefit_id = benefit_id;
    
    SELECT COUNT(*) INTO asignaciones_membresia
    FROM membershipbenefits mb
    WHERE mb.benefit_id = benefit_id;
    
    RETURN (asignaciones_audiencia > 1 OR asignaciones_membresia > 1);
END //
DELIMITER ;

-- 17. Calcular índice de variedad por ciudad
DELIMITER //
CREATE FUNCTION indice_variedad_ciudad(city_id VARCHAR(6))
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cantidad_empresas INT;
    DECLARE cantidad_productos INT;
    DECLARE indice DECIMAL(5,2);
    
    SELECT COUNT(DISTINCT c.id) INTO cantidad_empresas
    FROM companies c
    WHERE c.city_id = city_id;
    
    SELECT COUNT(DISTINCT cp.product_id) INTO cantidad_productos
    FROM companies c
    INNER JOIN companyproducts cp ON c.id = cp.company_id
    WHERE c.city_id = city_id;
    
    IF cantidad_empresas = 0 THEN
        SET indice = 0;
    ELSE
        SET indice = ROUND((cantidad_productos * 1.0) / cantidad_empresas, 2);
    END IF;
    
    RETURN indice;
END //
DELIMITER ;

-- 18. Evaluar si un producto debe ser desactivado por baja calificación
DELIMITER //
CREATE FUNCTION debe_desactivar_producto(product_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE promedio_calificacion DECIMAL(5,2);
    DECLARE total_calificaciones INT;
    DECLARE debe_desactivar BOOLEAN DEFAULT FALSE;
    
    SELECT AVG(qp.rating), COUNT(*) 
    INTO promedio_calificacion, total_calificaciones
    FROM quality_products qp
    WHERE qp.product_id = product_id;
    
    IF total_calificaciones >= 5 AND promedio_calificacion < 2.5 THEN
        SET debe_desactivar = TRUE;
    END IF;
    
    RETURN debe_desactivar;
END //
DELIMITER ;

-- 19. Calcular índice de popularidad de un producto
DELIMITER //
CREATE FUNCTION indice_popularidad_producto(product_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cantidad_favoritos INT;
    DECLARE promedio_rating DECIMAL(5,2);
    DECLARE indice DECIMAL(5,2);
    
    SELECT COUNT(*) INTO cantidad_favoritos
    FROM details_favorites df
    WHERE df.product_id = product_id;
    
    SELECT AVG(qp.rating) INTO promedio_rating
    FROM quality_products qp
    WHERE qp.product_id = product_id;
    
    SET promedio_rating = IFNULL(promedio_rating, 0);
    SET cantidad_favoritos = IFNULL(cantidad_favoritos, 0);
    
    SET indice = ROUND((promedio_rating * 0.7) + (cantidad_favoritos * 0.3), 2);
    
    RETURN indice;
END //
DELIMITER ;

-- 20. Generar código único basado en nombre del producto y fecha de creación
DELIMITER //
CREATE FUNCTION generar_codigo_producto(product_id INT)
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE nombre_producto VARCHAR(60);
    DECLARE fecha_creacion DATE;
    DECLARE codigo VARCHAR(50);
    
    SELECT p.name, DATE(p.updated_at) 
    INTO nombre_producto, fecha_creacion
    FROM products p
    WHERE p.id = product_id;
    
    SET codigo = CONCAT(
        UPPER(SUBSTRING(REPLACE(nombre_producto, ' ', ''), 1, 8)),
        '_',
        DATE_FORMAT(fecha_creacion, '%Y%m%d'),
        '_',
        LPAD(product_id, 4, '0')
    );
    
    RETURN codigo;
END //
DELIMITER ;
