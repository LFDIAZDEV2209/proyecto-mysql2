-- Events

-- 1. Como administrador, quiero un evento que borre productos sin actividad cada 6 meses.

SET GLOBAL event_scheduler = ON;

-- Procedimiento almacenado para eliminar productos sin actividad
DELIMITER //

CREATE PROCEDURE DeleteInactiveProducts()
BEGIN
    DECLARE products_deleted INT DEFAULT 0;
    
    DELETE FROM products 
    WHERE id NOT IN (
        SELECT DISTINCT product_id FROM quality_products
        UNION
        SELECT DISTINCT product_id FROM details_favorites
        UNION
        SELECT DISTINCT product_id FROM companyproducts
    );
    
    SET products_deleted = ROW_COUNT();
    
    SELECT CONCAT('Cleanup completed: ', products_deleted, ' inactive products deleted') AS result;
END //

DELIMITER ;

-- Evento que ejecuta el procedimiento cada 6 meses

DELIMITER //

CREATE EVENT cleanup_inactive_products
ON SCHEDULE EVERY 6 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL DeleteInactiveProducts();
END //

DELIMITER ;

-- 2. Como supervisor, deseo un evento semanal que recalcula el promedio de calificaciones.

-- Procedimiento para recalcular promedios
DELIMITER //

CREATE PROCEDURE RecalculateProductAverages()
BEGIN
    DECLARE products_updated INT DEFAULT 0;
    
    INSERT INTO product_metrics (product_id, average_rating, total_ratings)
    SELECT 
        p.id,
        AVG(qp.rating) as avg_rating,
        COUNT(qp.rating) as total_ratings
    FROM products p
    LEFT JOIN quality_products qp ON p.id = qp.product_id
    GROUP BY p.id
    ON DUPLICATE KEY UPDATE
        average_rating = VALUES(average_rating),
        total_ratings = VALUES(total_ratings),
        last_updated = CURRENT_TIMESTAMP;
    
    SET products_updated = ROW_COUNT();
    
    SELECT CONCAT('Recalculation completed: ', products_updated, ' products updated') AS result;
END //

DELIMITER ;

-- Evento semanal para recalcular promedios
DELIMITER //

CREATE EVENT recalculate_product_averages_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL RecalculateProductAverages();
END //

DELIMITER ;

-- 3. Como operador, quiero un evento mensual que actualice los precios de productos por inflación.

-- Procedimiento para actualizar precios por inflación
DELIMITER //

CREATE PROCEDURE UpdatePricesByInflation()
BEGIN
    DECLARE products_updated INT DEFAULT 0;
    
    UPDATE companyproducts SET price = price * 1.03;
    
    SET products_updated = ROW_COUNT();
    
    SELECT CONCAT('Inflation update completed: ', products_updated, ' products updated') AS result;
END //

DELIMITER ;

-- Evento mensual para actualizar precios
DELIMITER //

CREATE EVENT update_prices_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL UpdatePricesByInflation();
END //

DELIMITER ;

-- 4. Como auditor, deseo un evento que genere un backup lógico cada medianoche.

DELIMITER //

CREATE PROCEDURE CreateLogicalBackup()
BEGIN
    CREATE TABLE IF NOT EXISTS products_backup AS SELECT * FROM products;
    CREATE TABLE IF NOT EXISTS rates_backup AS SELECT * FROM rates;
    SELECT 'Logical backup completed successfully' AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT daily_logical_backup
ON SCHEDULE EVERY 1 DAY STARTS '00:00:00'
DO
BEGIN
    CALL CreateLogicalBackup();
END //

DELIMITER ;

-- 5. Como cliente, quiero un evento que me recuerde los productos que tengo en favoritos y no he calificado.

DELIMITER //

CREATE PROCEDURE GenerateFavoriteReminders()
BEGIN
    INSERT INTO notifications (customer_id, message)
    SELECT DISTINCT f.customer_id, 
           CONCAT('You have ', COUNT(df.product_id), ' products in favorites that you haven\'t rated yet)
    FROM favorites f
    JOIN details_favorites df ON f.id = df.favorite_id
    LEFT JOIN quality_products qp ON df.product_id = qp.product_id AND f.customer_id = qp.customer_id
    WHERE qp.product_id IS NULL
    GROUP BY f.customer_id;
    
    SELECT CONCAT('Reminders generated for ', ROW_COUNT(), ' customers') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_favorite_reminders
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL GenerateFavoriteReminders();
END //

DELIMITER ;

-- 6. Como técnico, deseo un evento que revise inconsistencias entre empresas y productos cada domingo.

DELIMITER //

CREATE PROCEDURE CheckCompanyProductInconsistencies()
BEGIN
    INSERT INTO errores_log (error_message)
    SELECT CONCAT('Product without company: ', p.id, ' - ', p.name)
    FROM products p
    WHERE NOT EXISTS (SELECT 1 FROM companyproducts cp WHERE cp.product_id = p.id);
    
    INSERT INTO errores_log (error_message)
    SELECT CONCAT('Company without products: ', c.id, ' - ', c.name)
    FROM companies c
    WHERE NOT EXISTS (SELECT 1 FROM companyproducts cp WHERE cp.company_id = c.id);
    
    SELECT CONCAT('Inconsistencies check completed: ', ROW_COUNT(), ' errors found') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_inconsistencies_check
ON SCHEDULE EVERY 1 WEEK ON SUNDAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL CheckCompanyProductInconsistencies();
END //

DELIMITER ;

-- 7. Como administrador, quiero un evento que archive membresías vencidas.

DELIMITER //

CREATE PROCEDURE ArchiveExpiredMemberships()
BEGIN
    UPDATE customer_memberships 
    SET isactive = FALSE 
    WHERE end_date < CURDATE() AND isactive = TRUE;
    
    SELECT CONCAT('Expired memberships archived: ', ROW_COUNT(), ' memberships updated') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT daily_archive_expired_memberships
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL ArchiveExpiredMemberships();
END //

DELIMITER ;

-- 8. Como supervisor, deseo un evento que notifique por correo sobre beneficios nuevos.

DELIMITER //

CREATE PROCEDURE NotifyNewBenefits()
BEGIN
    INSERT INTO notifications (customer_id, message)
    SELECT DISTINCT c.id, 
           CONCAT('New benefit available: ', b.description)
    FROM customers c
    CROSS JOIN benefits b
    WHERE b.id NOT IN (
        SELECT DISTINCT benefit_id 
        FROM membershipbenefits mb 
        JOIN customer_memberships cm ON mb.membership_id = cm.membership_id 
        WHERE cm.customer_id = c.id AND cm.isactive = TRUE
    );
    
    SELECT CONCAT('New benefits notifications sent: ', ROW_COUNT(), ' notifications') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_new_benefits_notification
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL NotifyNewBenefits();
END //

DELIMITER ;

-- 9. Como operador, quiero un evento que calcule el total de favoritos por cliente y lo guarde.

DELIMITER //

CREATE PROCEDURE CalculateCustomerFavorites()
BEGIN
    INSERT INTO favoritos_resumen (customer_id, total_favoritos, fecha_calculo)
    SELECT f.customer_id, COUNT(df.product_id), CURDATE()
    FROM favorites f
    JOIN details_favorites df ON f.id = df.favorite_id
    GROUP BY f.customer_id;
    
    SELECT CONCAT('Favorites summary calculated: ', ROW_COUNT(), ' customers processed') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_favorites_calculation
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL CalculateCustomerFavorites();
END //

DELIMITER ;

-- 10. Como auditor, deseo un evento que valide claves foráneas semanalmente y reporte errores.

DELIMITER //

CREATE PROCEDURE ValidateForeignKeys()
BEGIN
    INSERT INTO inconsistencias_fk (tabla_origen, campo_origen, valor_origen, tabla_referencia)
    SELECT 'quality_products', 'product_id', qp.product_id, 'products'
    FROM quality_products qp
    WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.id = qp.product_id);
    
    INSERT INTO inconsistencias_fk (tabla_origen, campo_origen, valor_origen, tabla_referencia)
    SELECT 'quality_products', 'customer_id', qp.customer_id, 'customers'
    FROM quality_products qp
    WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.id = qp.customer_id);
    
    INSERT INTO inconsistencias_fk (tabla_origen, campo_origen, valor_origen, tabla_referencia)
    SELECT 'quality_products', 'company_id', qp.company_id, 'companies'
    FROM quality_products qp
    WHERE NOT EXISTS (SELECT 1 FROM companies c WHERE c.id = qp.company_id);
    
    SELECT CONCAT('Foreign key validation completed: ', ROW_COUNT(), ' inconsistencies found') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_foreign_key_validation
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL ValidateForeignKeys();
END //

DELIMITER ;

-- 11. Como técnico, quiero un evento que elimine calificaciones con errores antiguos.

DELIMITER //

CREATE PROCEDURE DeleteInvalidRatings()
BEGIN
    DELETE FROM rates WHERE rating IS NULL OR rating < 0;
    
    SELECT CONCAT('Invalid ratings deleted: ', ROW_COUNT(), ' records removed') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_cleanup_invalid_ratings
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL DeleteInvalidRatings();
END //

DELIMITER ;

-- 12. Como desarrollador, deseo un evento que actualice encuestas que no se han usado en mucho tiempo.

DELIMITER //

CREATE PROCEDURE DeactivateUnusedPolls()
BEGIN
    UPDATE polls 
    SET isactive = FALSE 
    WHERE id NOT IN (
        SELECT DISTINCT poll_id 
        FROM quality_products 
        WHERE daterating > NOW() - INTERVAL 6 MONTH
    );
    
    SELECT CONCAT('Unused polls deactivated: ', ROW_COUNT(), ' polls updated') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_deactivate_unused_polls
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL DeactivateUnusedPolls();
END //

DELIMITER ;

-- 13. Como administrador, quiero un evento que inserte datos de auditoría periódicamente.

CREATE TABLE IF NOT EXISTS auditorias_diarias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    total_productos INT,
    total_clientes INT,
    total_empresas INT,
    total_calificaciones INT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE InsertDailyAudit()
BEGIN
    INSERT INTO auditorias_diarias (fecha, total_productos, total_clientes, total_empresas, total_calificaciones)
    SELECT 
        CURDATE(),
        (SELECT COUNT(*) FROM products),
        (SELECT COUNT(*) FROM customers),
        (SELECT COUNT(*) FROM companies),
        (SELECT COUNT(*) FROM quality_products);
    
    SELECT CONCAT('Daily audit inserted for: ', CURDATE()) AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT daily_audit_insert
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL InsertDailyAudit();
END //

DELIMITER ;

-- 14. Como gestor, deseo un evento que notifique a las empresas sus métricas de calidad cada lunes.

CREATE TABLE IF NOT EXISTS notificaciones_empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id VARCHAR(20),
    mensaje TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES companies(id)
);

DELIMITER //

CREATE PROCEDURE NotifyCompanyQualityMetrics()
BEGIN
    INSERT INTO notificaciones_empresa (empresa_id, mensaje)
    SELECT 
        c.id,
        CONCAT('Quality metrics for ', c.name, ': Average rating = ', 
               COALESCE(AVG(qp.rating), 0), ' from ', COUNT(qp.rating), ' ratings')
    FROM companies c
    LEFT JOIN quality_products qp ON c.id = qp.company_id
    GROUP BY c.id, c.name;
    
    SELECT CONCAT('Company quality notifications sent: ', ROW_COUNT(), ' notifications') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_company_quality_notification
ON SCHEDULE EVERY 1 WEEK ON MONDAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL NotifyCompanyQualityMetrics();
END //

DELIMITER ;

-- 15. Como cliente, quiero un evento que me recuerde renovar la membresía próxima a vencer.

DELIMITER //

CREATE PROCEDURE RemindMembershipRenewal()
BEGIN
    INSERT INTO notifications (customer_id, message)
    SELECT 
        cm.customer_id,
        CONCAT('Your membership expires in ', DATEDIFF(cm.end_date, CURDATE()), ' days. Please renew!')
    FROM customer_memberships cm
    WHERE cm.end_date BETWEEN CURDATE() AND CURDATE() + INTERVAL 7 DAY
    AND cm.isactive = TRUE;
    
    SELECT CONCAT('Membership renewal reminders sent: ', ROW_COUNT(), ' notifications') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT daily_membership_reminder
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL RemindMembershipRenewal();
END //

DELIMITER ;

-- 16. Como operador, deseo un evento que reordene estadísticas generales.

CREATE TABLE IF NOT EXISTS estadisticas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    productos_activos INT,
    clientes_registrados INT,
    empresas_activas INT,
    calificaciones_totales INT,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE UpdateGeneralStatistics()
BEGIN
    INSERT INTO estadisticas (fecha, productos_activos, clientes_registrados, empresas_activas, calificaciones_totales)
    SELECT 
        CURDATE(),
        (SELECT COUNT(*) FROM products WHERE average_rating IS NOT NULL),
        (SELECT COUNT(*) FROM customers),
        (SELECT COUNT(*) FROM companies),
        (SELECT COUNT(*) FROM quality_products);
    
    SELECT CONCAT('General statistics updated for: ', CURDATE()) AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT weekly_statistics_update
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL UpdateGeneralStatistics();
END //

DELIMITER ;

-- 17. Como técnico, quiero un evento que cree resúmenes temporales por categoría.

CREATE TABLE IF NOT EXISTS resumen_categoria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT,
    nombre_categoria VARCHAR(60),
    productos_calificados INT,
    promedio_calificacion DOUBLE(10,2),
    fecha_calculo DATE,
    FOREIGN KEY (categoria_id) REFERENCES categories(id)
);

DELIMITER //

CREATE PROCEDURE CreateCategorySummary()
BEGIN
    INSERT INTO resumen_categoria (categoria_id, nombre_categoria, productos_calificados, promedio_calificacion, fecha_calculo)
    SELECT 
        c.id,
        c.description,
        COUNT(DISTINCT p.id),
        AVG(qp.rating)
    FROM categories c
    LEFT JOIN products p ON c.id = p.category_id
    LEFT JOIN quality_products qp ON p.id = qp.product_id
    GROUP BY c.id, c.description;
    
    SELECT CONCAT('Category summary created: ', ROW_COUNT(), ' categories processed') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_category_summary
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL CreateCategorySummary();
END //

DELIMITER ;

-- 18. Como gerente, deseo un evento que desactive beneficios que ya expiraron.

DELIMITER //

CREATE PROCEDURE DeactivateExpiredBenefits()
BEGIN
    UPDATE benefits 
    SET isactive = FALSE 
    WHERE expires_at < CURDATE() AND isactive = TRUE;
    
    SELECT CONCAT('Expired benefits deactivated: ', ROW_COUNT(), ' benefits updated') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT daily_deactivate_expired_benefits
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL DeactivateExpiredBenefits();
END //

DELIMITER ;

-- 19. Como auditor, quiero un evento que genere alertas sobre productos sin evaluación anual.

CREATE TABLE IF NOT EXISTS alertas_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    nombre_producto VARCHAR(60),
    dias_sin_evaluacion INT,
    fecha_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

DELIMITER //

CREATE PROCEDURE AlertProductsWithoutAnnualEvaluation()
BEGIN
    INSERT INTO alertas_productos (product_id, nombre_producto, dias_sin_evaluacion)
    SELECT 
        p.id,
        p.name,
        DATEDIFF(CURDATE(), COALESCE(MAX(qp.daterating), '1900-01-01'))
    FROM products p
    LEFT JOIN quality_products qp ON p.id = qp.product_id
    GROUP BY p.id, p.name
    HAVING DATEDIFF(CURDATE(), COALESCE(MAX(qp.daterating), '1900-01-01')) > 365;
    
    SELECT CONCAT('Product evaluation alerts generated: ', ROW_COUNT(), ' alerts') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_product_evaluation_alert
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL AlertProductsWithoutAnnualEvaluation();
END //

DELIMITER ;

-- 20. Como administrador, deseo un evento que actualice precios según un índice referenciado.

CREATE TABLE IF NOT EXISTS inflacion_indice (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    indice_multiplicador DOUBLE(10,4),
    descripcion VARCHAR(100),
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE UpdatePricesByInflationIndex()
BEGIN
    DECLARE current_index DOUBLE DEFAULT 1.03;
    
    SELECT indice_multiplicador INTO current_index 
    FROM inflacion_indice 
    ORDER BY fecha DESC 
    LIMIT 1;
    
    UPDATE companyproducts 
    SET price = price * COALESCE(current_index, 1.03);
    
    SELECT CONCAT('Prices updated with inflation index: ', ROW_COUNT(), ' products updated') AS result;
END //

DELIMITER ;

DELIMITER //

CREATE EVENT monthly_price_inflation_update
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL UpdatePricesByInflationIndex();
END //

DELIMITER ;


