-- Procedimientos

-- 1. Como desarrollador, quiero un procedimiento que registre una calificación y actualice el promedio del producto.

ALTER TABLE products ADD COLUMN IF NOT EXISTS average_rating DOUBLE(10,2) DEFAULT NULL;

DELIMITER //

CREATE PROCEDURE RegisterRating(
    IN p_product_id INT,
    IN p_customer_id INT,
    IN p_rating DOUBLE(10,2)
)
BEGIN
    INSERT INTO rates (customer_id, company_id, poll_id, daterating, rating)
    SELECT p_customer_id, cp.company_id, 1, NOW(), p_rating
    FROM companyproducts cp
    WHERE cp.product_id = p_product_id
    LIMIT 1
    ON DUPLICATE KEY UPDATE 
        daterating = NOW(),
        rating = p_rating;

    UPDATE products 
    SET average_rating = (
        SELECT AVG(r.rating) 
        FROM rates r
        JOIN companyproducts cp ON r.company_id = cp.company_id
        WHERE cp.product_id = p_product_id
    ) 
    WHERE id = p_product_id;
END //

DELIMITER ;

CALL RegisterRating(24, 1, 4.5);

-- 2. Como administrador, deseo un procedimiento para insertar una empresa y asociar productos por defecto.

DELIMITER //

CREATE PROCEDURE InsertCompanyAndProducts(
    IN p_company_id VARCHAR(20),
    IN p_type_id INT(11),
    IN p_name VARCHAR(80),
    IN p_category_id INT(11),
    IN p_city_id VARCHAR(6),
    IN p_audience_id INT(11),
    IN p_cellphone VARCHAR(15),
    IN p_email VARCHAR(80)
)
BEGIN
    INSERT INTO companies (id, type_id, name, category_id, city_id, audience_id, cellphone, email)
    VALUES (p_company_id, p_type_id, p_name, p_category_id, p_city_id, p_audience_id, p_cellphone, p_email);
    
    INSERT INTO companyproducts (company_id, product_id, price, unitmeasure_id)
    SELECT p_company_id, p.id, p.price,
           CASE 
               WHEN p.category_id = 1 THEN 1  
               WHEN p.category_id = 2 THEN 2  
               WHEN p.category_id = 3 THEN 6  
               WHEN p.category_id = 4 THEN 2  
               WHEN p.category_id = 5 THEN 6  
               WHEN p.category_id = 6 THEN 5  
               WHEN p.category_id = 7 THEN 5  
               WHEN p.category_id = 8 THEN 1  
               WHEN p.category_id = 9 THEN 1  
               WHEN p.category_id = 10 THEN 1 
               ELSE 1
           END as unitmeasure_id
    FROM products p
    WHERE p.category_id = p_category_id
    LIMIT 3;
    
    SELECT CONCAT('Empresa ', p_name, ' creada exitosamente con ID: ', p_company_id) as mensaje;
    
END //

DELIMITER ;

CALL InsertCompanyAndProducts('COMP016', 2, 'Nueva Tech Solutions', 1, '05001', 1, '5743001234569', 'info@nuevatech.com');

-- Prueba 
SELECT c.id, c.name, c.category_id, p.name as producto, cp.price, um.description as unidad_medida
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
LEFT JOIN unitofmeasure um ON cp.unitmeasure_id = um.id
WHERE c.id IN ('COMP016')
ORDER BY c.id, p.name;

-- 3. Como cliente, quiero un procedimiento que añada un producto favorito y verifique duplicados.

DELIMITER //

CREATE PROCEDURE AddFavoriteProduct(
    IN p_customer_id INT(11),
    IN p_product_id INT(11)
)
BEGIN 
    DECLARE v_favorite_id INT;
    DECLARE v_company_id VARCHAR(20);
    
    IF NOT EXISTS (
        SELECT 1
        FROM details_favorites df
        JOIN favorites f ON df.favorite_id = f.id
        WHERE f.customer_id = p_customer_id 
        AND df.product_id = p_product_id
    ) THEN
        SELECT company_id INTO v_company_id
        FROM companyproducts cp
        WHERE cp.product_id = p_product_id
        LIMIT 1;
        
        SELECT id INTO v_favorite_id
        FROM favorites
        WHERE customer_id = p_customer_id AND company_id = v_company_id;
        
        IF v_favorite_id IS NOT NULL THEN
            INSERT INTO details_favorites (favorite_id, product_id)
            VALUES (v_favorite_id, p_product_id);
        ELSE
            INSERT INTO favorites (customer_id, company_id)
            VALUES (p_customer_id, v_company_id);
            
            INSERT INTO details_favorites (favorite_id, product_id)
            VALUES (LAST_INSERT_ID(), p_product_id);
        END IF;
    END IF;
END //

DELIMITER ;

CALL AddFavoriteProduct(1, 24);

-- Prueba 
SELECT 
    c.name as cliente,
    comp.name as empresa,
    p.name as producto,
    f.id as favorite_id
FROM customers c
JOIN favorites f ON c.id = f.customer_id
JOIN companies comp ON f.company_id = comp.id
JOIN details_favorites df ON f.id = df.favorite_id
JOIN products p ON df.product_id = p.id
WHERE c.id IN (1)
ORDER BY c.id, p.name;

-- 4. Como gestor, deseo un procedimiento que genere un resumen mensual de calificaciones por empresa.

DELIMITER //

CREATE PROCEDURE GenerateMonthlyRatingSummary(
    IN p_company_id VARCHAR(20),
    IN p_month INT,
    IN p_year INT
)
BEGIN 
    DECLARE v_total_calificaciones INT;
    DECLARE v_promedio_calificacion DOUBLE(10,2);

    SELECT 
        COUNT(*) as total,
        AVG(rating) as promedio
    INTO v_total_calificaciones, v_promedio_calificacion
    FROM rates
    WHERE company_id = p_company_id
    AND MONTH(daterating) = p_month
    AND YEAR(daterating) = p_year;

    IF v_total_calificaciones IS NULL THEN
        SET v_total_calificaciones = 0;
        SET v_promedio_calificacion = 0.0;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM resumen_calificaciones rc
        WHERE rc.empresa_id = p_company_id
        AND rc.mes = p_month
        AND rc.año = p_year
    ) THEN
        UPDATE resumen_calificaciones
        SET promedio_calificacion = v_promedio_calificacion,
            total_calificaciones = v_total_calificaciones,
            fecha_generacion = NOW()
        WHERE empresa_id = p_company_id
        AND mes = p_month
        AND año = p_year;
    ELSE
        INSERT INTO resumen_calificaciones (empresa_id, mes, año, promedio_calificacion, total_calificaciones, fecha_generacion)
        VALUES (p_company_id, p_month, p_year, v_promedio_calificacion, v_total_calificaciones, NOW());
    END IF;
    
    SELECT 
        empresa_id,
        mes,
        año,
        promedio_calificacion,
        total_calificaciones,
        fecha_generacion
    FROM resumen_calificaciones
    WHERE empresa_id = p_company_id
    AND mes = p_month
    AND año = p_year;
END //

DELIMITER ;

CALL GenerateMonthlyRatingSummary('COMP001', 7, 2025);

-- 5. Como supervisor, quiero un procedimiento que calcule beneficios activos por membresía.

DELIMITER //

CREATE PROCEDURE CalculateActivateBenefits()
BEGIN
    SELECT 
        m.name AS membresia,
        p.name AS periodo,
        a.description AS publico,
        b.description AS beneficio,
        mp.price AS precio
    FROM membershipbenefits mb
    JOIN memberships m ON mb.membership_id = m.id
    JOIN periods p ON mb.period_id = p.id
    JOIN audiences a ON mb.audience_id = a.id
    JOIN benefits b ON mb.benefit_id = b.id
    JOIN membershipperiods mp ON mb.membership_id = mp.membership_id 
        AND mb.period_id = mp.period_id;
END //

DELIMITER ;

CALL CalculateActivateBenefits();

-- 6. Como técnico, deseo un procedimiento que elimine productos sin calificación ni empresa asociada.

DELIMITER //

CREATE PROCEDURE DeleteProductsWithoutRating()
BEGIN
    DELETE FROM products
    WHERE id NOT IN (
        SELECT product_id
        FROM companyproducts
    )
    AND average_rating IS NULL;
END //

DELIMITER ;

CALL DeleteProductsWithoutRating();

-- 7. Como operador, quiero un procedimiento que actualice precios de productos por categoría.

DELIMITER //

CREATE PROCEDURE UpdateProductPricesByCategory(
    IN p_category_id INT(11),
    IN p_price DOUBLE(10,2)
)
BEGIN
    UPDATE companyproducts
    SET price = p_price
    WHERE product_id IN (
        SELECT id
    )
    AND company_id IN (
        SELECT id
        FROM companies
        WHERE category_id = p_category_id
    );
END //

DELIMITER ;

CALL UpdateProductPricesByCategory(1, 100000);

-- 8. Como auditor, deseo un procedimiento que liste inconsistencias entre rates y quality_products.

DELIMITER //

CREATE PROCEDURE ListInconsistencies()
BEGIN
    SELECT
        r.rating AS rate_rating,
        qp.rating AS quality_rating
    FROM rates r
    JOIN polls p ON r.poll_id = p.id
    JOIN quality_products qp ON qp.poll_id = p.id
    WHERE r.rating <> qp.rating;

END //

DELIMITER ;

CALL ListInconsistencies();

-- 9. Como desarrollador, quiero un procedimiento que asigne beneficios a nuevas audiencias.

DELIMITER //

CREATE PROCEDURE AssignBenefitsToNewAudiences(
    IN p_audience_id INT(11),
    IN p_benefit_id INT(11)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM audiencebenefits
        WHERE audience_id = p_audience_id AND benefit_id = p_benefit_id
    ) THEN
        INSERT INTO audiencebenefits (audience_id, benefit_id)
        VALUES (p_audience_id, p_benefit_id);

        SELECT CONCAT('Beneficio ', p_benefit_id, ' asignado a audiencia ', p_audience_id) AS mensaje;
    ELSE
        SELECT CONCAT('El beneficio ', p_benefit_id, ' ya está asignado a la audiencia ', p_audience_id) AS mensaje;
    END IF;
END //

DELIMITER ;

CALL AssignBenefitsToNewAudiences(3, 2);

-- 10. Como administrador, deseo un procedimiento que active planes de membresía vencidos si el pago fue confirmado.

ALTER TABLE customer_memberships ADD COLUMN payment_confirmed BOOLEAN DEFAULT FALSE;

DELIMITER //

CREATE PROCEDURE ActivateExpiredMemberships()
BEGIN
    UPDATE customer_memberships mp
    SET isactive = TRUE
    WHERE end_date < CURDATE()
    AND payment_confirmed = TRUE;
    SELECT 
        mp.membership_id,
        mp.isactive
    FROM customer_memberships mp
    WHERE mp.isactive = TRUE;
END //

DELIMITER ;

-- Prueba de activación de membresías vencidas y lista de membresías activas
CALL ActivateExpiredMemberships();

-- 11. Como cliente, deseo un procedimiento que me devuelva todos mis productos favoritos con su promedio de rating.

DROP PROCEDURE IF EXISTS GetFavoriteProductsWithRating;

DELIMITER //

CREATE PROCEDURE GetFavoriteProductsWithRating(
    IN p_customer_id INT(11)
)
BEGIN 
    SELECT
        p.name AS product_name,
        AVG(qp.rating) AS average_rating
    FROM customers c
    JOIN favorites f ON c.id = f.customer_id
    JOIN details_favorites df ON f.id = df.favorite_id
    JOIN products p ON df.product_id = p.id
    LEFT JOIN quality_products qp ON p.id = qp.product_id
    WHERE c.id = p_customer_id
    GROUP BY p.id
    ORDER BY average_rating DESC;
END //

DELIMITER ;

CALL GetFavoriteProductsWithRating(2);

-- 12. Como gestor, quiero un procedimiento que registre una encuesta y sus preguntas asociadas.

DELIMITER //

CREATE PROCEDURE RegisterPoll(
    IN p_poll_name VARCHAR(80),
    IN p_poll_description TEXT,
    IN p_isactive BOOLEAN,
    IN p_categorypoll_id INT(11),
    IN p_questions TEXT
)
BEGIN
    DECLARE v_poll_id INT;
    DECLARE v_question TEXT;
    DECLARE i INT DEFAULT 1;
    DECLARE total INT;

    INSERT INTO polls (name, description, isactive, categorypoll_id)
    VALUES (p_poll_name, p_poll_description, p_isactive, p_categorypoll_id);

    SET v_poll_id = LAST_INSERT_ID();

    SET total = LENGTH(p_questions) - LENGTH(REPLACE(p_questions, ';', '')) + 1;

    WHILE i <= total DO
        SET v_question = SUBSTRING_INDEX(SUBSTRING_INDEX(p_questions, ';', i), ';', -1);
        INSERT INTO poll_questions (poll_id, question_text)
        VALUES (v_poll_id, v_question);
        SET i = i + 1;
    END WHILE;

    SELECT CONCAT('Encuesta "', p_poll_name, '" registrada con ID: ', v_poll_id) AS mensaje;
END //

DELIMITER ;

CALL RegisterPoll(
    'Encuesta de Satisfacción',
    'Encuesta para medir la satisfacción del cliente con nuestros productos.',
    TRUE,
    1,
    '¿Cómo calificaría nuestro producto?;¿Recomendaría este producto a otros?;¿Qué mejorarías en el producto?'
);

-- 13. Como técnico, deseo un procedimiento que borre favoritos antiguos no calificados en más de un año.

DELIMITER //

CREATE PROCEDURE DeleteOldFavorites()

BEGIN 
    DELETE FROM details_favorites
    WHERE product_id IN (
        SELECT p.id
        FROM products p
        LEFT JOIN quality_products qp ON p.id = qp.product_id
        WHERE qp.daterating < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) OR qp.daterating IS NULL
    )
END //

DELIMITER ;

CALL DeleteOldFavorites();

-- 14. Como operador, quiero un procedimiento que asocie automáticamente beneficios por audiencia.

DELIMITER //

CREATE PROCEDURE AssociateBenefitsByAudience()
BEGIN
    INSERT INTO audiencebenefits (audience_id, benefit_id)
    SELECT DISTINCT a.id, b.id
    FROM audiences a
    CROSS JOIN benefits b
    WHERE NOT EXISTS (
        SELECT 1
        FROM audiencebenefits ab
        WHERE ab.audience_id = a.id AND ab.benefit_id = b.id
    );
    
    SELECT 'Beneficios asociados por audiencia exitosamente.' AS mensaje;
END //

DELIMITER ;

CALL AssociateBenefitsByAudience();

-- 15. Como administrador, deseo un procedimiento para generar un historial de cambios de precio.

DELIMITER //

CREATE PROCEDURE GeneratePriceChangeHistory()
BEGIN 
    INSERT INTO historial_precios (product_id, old_price, new_price)
    SELECT cp.product_id, cp.price, p.price
    FROM companyproducts cp
    JOIN products p ON cp.product_id = p.id
    WHERE cp.price <> p.price;

    UPDATE companyproducts cp
    JOIN products p ON cp.product_id = p.id
    SET cp.price = p.price
    WHERE cp.price <> p.price;

    SELECT 'Historial de cambios de precio generado exitosamente.' AS mensaje;
END //

DELIMITER ;

CALL GeneratePriceChangeHistory();

-- 16. Como desarrollador, quiero un procedimiento que registre automáticamente una nueva encuesta activa.

DELIMITER //

CREATE PROCEDURE RegisterActivePoll(
    IN p_poll_name VARCHAR(80),
    IN p_poll_description TEXT,
    IN p_categorypoll_id INT(11),
    IN p_questions TEXT
)
BEGIN 
    DECLARE v_poll_id INT;

    INSERT INTO polls (name, description, isactive, categorypoll_id)
    VALUES (p_poll_name, p_poll_description, TRUE, p_categorypoll_id);

    SET v_poll_id = LAST_INSERT_ID();

    INSERT INTO poll_questions (poll_id, question_text)
    SELECT v_poll_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_questions, ';', n.n), ';', -1))
    FROM (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) n
    WHERE n.n <= LENGTH(p_questions) - LENGTH(REPLACE(p_questions, ';', '')) + 1;

    SELECT CONCAT('Encuesta activa "', p_poll_name, '" registrada con ID: ', v_poll_id) AS mensaje;
END //

DELIMITER ;

-- Prueba de registro de encuesta activa
CALL RegisterActivePoll(
    'Encuesta de Satisfacción del Cliente',
    'Queremos conocer su opinión sobre nuestros productos y servicios.',
    1,
    '¿Cómo calificaría nuestro servicio?;¿Qué mejorarías en nuestra atención al cliente?;¿Recomendaría nuestra empresa a otros?'
);
    
-- 17. Como técnico, deseo un procedimiento que actualice la unidad de medida de productos sin afectar si hay ventas.  

DELIMITER //

CREATE PROCEDURE UpdateProductUnitMeasure(
    IN p_product_id INT(11),
    IN p_new_unitmeasure_id INT(11)
)
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count
    FROM companyproducts
    WHERE product_id = p_product_id;

    IF v_count = 0 THEN
        UPDATE products
        SET unitmeasure_id = p_new_unitmeasure_id
        WHERE id = p_product_id;
        
        SELECT CONCAT('Unidad de medida del producto ', p_product_id, ' actualizada a ', p_new_unitmeasure_id) AS mensaje;
    ELSE
        SELECT 'No se puede actualizar la unidad de medida porque el producto tiene ventas asociadas.' AS mensaje;
    END IF;
END //

DELIMITER ;

CALL UpdateProductUnitMeasure(24, 2);

--18. Como supervisor, quiero un procedimiento que recalcule todos los promedios de calidad cada semana.

DELIMITER //

CREATE PROCEDURE RecalculateQualityAverages()
BEGIN
    UPDATE products p
    SET average_rating = (
        SELECT AVG(qp.rating)
        FROM quality_products qp
        WHERE qp.product_id = p.id
    )
    WHERE EXISTS (
        SELECT 1
        FROM quality_products qp
        WHERE qp.product_id = p.id
    );
    
    SELECT 'Promedios de calidad recalculados exitosamente.' AS mensaje;
END //

DELIMITER ;

CALL RecalculateQualityAverages();

-- 19. Como auditor, deseo un procedimiento que valide claves foráneas cruzadas entre calificaciones y encuestas.

DELIMITER //

CREATE PROCEDURE ValidateForeignKeys()
BEGIN
    SELECT 
        'Validación de claves foráneas cruzadas entre calificaciones y encuestas' AS mensaje,
        COUNT(*) AS total_inconsistencias
    FROM rates r
    LEFT JOIN polls p ON r.poll_id = p.id
    WHERE p.id IS NULL;
END //

DELIMITER ;

CALL ValidateForeignKeys();

-- 20. Como gerente, quiero un procedimiento que genere el top 10 de productos más calificados por ciudad.

DELIMITER //

CREATE PROCEDURE TopRatedProductsByCity(
    IN p_city_code VARCHAR(6)
)
BEGIN 
    SELECT 
        p.name AS product_name,
        AVG(qp.rating) AS average_rating,
        c.name AS city_name
        FROM products p
        JOIN quality_products qp ON p.id = qp.product_id
        JOIN companies co ON qp.company_id = co.id
        JOIN citiesormunicipalities c ON co.city_id = c.code
    WHERE c.code = p_city_code
    GROUP BY p.id, c.name
    ORDER BY average_rating DESC
    LIMIT 10;
END //

DELIMITER ;

CALL TopRatedProductsByCity('05001');
