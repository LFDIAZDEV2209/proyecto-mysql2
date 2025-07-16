-- Triggers

ALTER TABLE products
ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 1. Actualizar la fecha de modificación de un producto

DELIMITER //

CREATE TRIGGER update_product_modification_date
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;

UPDATE products SET name = 'Updated Product Name', price = 19.99 WHERE id = 1;

-- 2. Como administrador, quiero un trigger que registre en log cuando un cliente califica un producto.

DELIMITER //

CREATE TRIGGER log_product_rating
AFTER INSERT ON quality_products
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (message)
    VALUES (CONCAT('Customer ', NEW.customer_id, ' rated product ', NEW.product_id, ' with rating ', NEW.rating));
END //

DELIMITER ;

INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
VALUES (24, 1, 1, 'COMP001', NOW(), 4.5);

-- 3. Como técnico, deseo un trigger que impida insertar productos sin unidad de medida.

DELIMITER //

CREATE TRIGGER prevent_product_without_unit_of_measure
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN 
    IF NEW.unitmeasure_id IS NULL OR NEW.unitmeasure_id = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unit of measure is required for products';
    END IF;
END //

DELIMITER ;

INSERT INTO companyproducts (company_id, product_id, price)
VALUES ('COMP001', 24, 19.99);

-- 4. Como auditor, quiero un trigger que verifique que las calificaciones no superen el valor máximo permitido.

DELIMITER //

CREATE TRIGGER check_rating_limit
BEFORE INSERT ON quality_products
FOR EACH ROW
BEGIN 
    IF NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating cannot exceed 5';
    END IF;
END //

DELIMITER ;

INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
VALUES (24, 1, 1, 'COMP001', NOW(), 6);

-- 5. Como supervisor, deseo un trigger que actualice automáticamente el estado de membresía al vencer el periodo.

DELIMITER //

CREATE TRIGGER update_membership_status
AFTER UPDATE ON customer_memberships
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        UPDATE customer_memberships
        SET isactive = FALSE
        WHERE customer_id = NEW.customer_id AND membership_id = NEW.membership_id;
    END IF;
END //

DELIMITER ;

-- 6. Como operador, quiero un trigger que evite duplicar productos por nombre dentro de una misma empresa.

DELIMITER //

CREATE TRIGGER prevent_duplicate_product_name
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM companyproducts WHERE company_id = NEW.company_id AND product_id = NEW.product_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product already exists';
    END IF;
END //

DELIMITER ;

INSERT INTO companyproducts (company_id, product_id, price, unitmeasure_id)
VALUES ('COMP001', 24, 19.99, 1);

-- 7. Como cliente, deseo un trigger que envíe notificación cuando añado un producto como favorito.

DELIMITER //

CREATE TRIGGER send_notification_when_adding_favorite
AFTER INSERT ON favorites
FOR EACH ROW
BEGIN 
    INSERT INTO notifications (customer_id, message)
    VALUES (NEW.customer_id, CONCAT('You have added ', NEW.company_id, ' to your favorites'));
END //

DELIMITER ;

INSERT INTO favorites (customer_id, company_id)
VALUES (1, 'COMP001');

-- 8. Como técnico, quiero un trigger que inserte una fila en quality_products cuando se registra una calificación.

DROP TRIGGER IF EXISTS insert_quality_product_when_rating_is_registered;

DELIMITER //

CREATE TRIGGER insert_quality_product_when_rating_is_registered
AFTER INSERT ON rates
FOR EACH ROW
BEGIN 
    INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
    SELECT cp.product_id, NEW.customer_id, NEW.poll_id, NEW.company_id, NEW.daterating, NEW.rating
    FROM companyproducts cp
    WHERE cp.company_id = NEW.company_id
    LIMIT 1
    ON DUPLICATE KEY UPDATE
        daterating = NEW.daterating,
        rating = NEW.rating;
END //

DELIMITER ;

INSERT INTO rates (customer_id, company_id, poll_id, daterating, rating)
VALUES (1, 'COMP001', 2, NOW(), 4.5);

-- 9. Como desarrollador, deseo un trigger que elimine los favoritos si se elimina el producto.

DELIMITER //

CREATE TRIGGER delete_favorites_when_product_is_deleted
AFTER DELETE ON products
FOR EACH ROW
BEGIN 
    -- Eliminar detalles de favoritos del producto eliminado
    DELETE FROM details_favorites WHERE product_id = OLD.id;
    
    -- Eliminar favoritos que quedan sin productos (usando tabla temporal)
    DELETE FROM favorites 
    WHERE id NOT IN (
        SELECT DISTINCT favorite_id 
        FROM details_favorites
    );
END //

DELIMITER ;

-- 10. Como administrador, quiero un trigger que bloquee la modificación de audiencias activas.

ALTER TABLE audiences
ADD COLUMN isactive BOOLEAN;

DELIMITER //

CREATE TRIGGER prevent_modification_of_active_audiences
BEFORE UPDATE ON audiences
FOR EACH ROW
BEGIN
    IF NEW.isactive = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify active audiences';
    END IF;
END //

DELIMITER ;

UPDATE audiences SET isactive = TRUE WHERE id = 1;

-- 11. Como gestor, deseo un trigger que actualice el promedio de calidad del producto tras una nueva evaluación.

DELIMITER //

CREATE TRIGGER update_product_average_rating
AFTER INSERT ON quality_products
FOR EACH ROW
BEGIN
    UPDATE products 
    SET average_rating = (
        SELECT AVG(rating)
        FROM quality_products
        WHERE product_id = NEW.product_id
    )
    WHERE id = NEW.product_id;
END //

DELIMITER ;

INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
VALUES (25, 1, 2, 'COMP001', NOW(), 4.5);

-- 12. Como auditor, quiero un trigger que registre cada vez que se asigna un nuevo beneficio.

DELIMITER //

CREATE TRIGGER register_new_membership_benefit
AFTER INSERT ON membershipbenefits
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (message)
    VALUES (CONCAT('New membership benefit assigned: ', NEW.benefit_id, ' to membership ', NEW.membership_id, ' for period ', NEW.period_id, ' and audience ', NEW.audience_id));
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER register_new_audience_benefit
AFTER INSERT ON audiencebenefits
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (message)
    VALUES (CONCAT('New audience benefit assigned: ', NEW.benefit_id, ' to audience ', NEW.audience_id));
END //

DELIMITER ;

-- 13. Como cliente, deseo un trigger que me impida calificar el mismo producto dos veces seguidas.

DELIMITER //

CREATE TRIGGER prevent_duplicate_rating
BEFORE INSERT ON quality_products
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM quality_products WHERE product_id = NEW.product_id AND customer_id = NEW.customer_id AND poll_id = NEW.poll_id AND company_id = NEW.company_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have already rated this product';
    END IF;
END //

DELIMITER ;

INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
VALUES (25, 1, 1, 'COMP001', NOW(), 4.5);

-- 14. Como técnico, quiero un trigger que valide que el email del cliente no se repita.

DELIMITER //

CREATE TRIGGER validate_customer_email
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN 
    IF EXISTS (SELECT 1 FROM customers WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;
END //

DELIMITER ;

INSERT INTO customers (name, email, cellphone)
VALUES ('John Doe', 'john.doe@example.com', '1234567890');

-- 15. Como operador, deseo un trigger que elimine registros huérfanos de details_favorites.

DELIMITER //

CREATE TRIGGER delete_orphan_details_favorites
AFTER DELETE ON favorites
FOR EACH ROW
BEGIN 
    DELETE FROM details_favorites WHERE favorite_id = OLD.id;
END //

DELIMITER ;

-- 16. Como administrador, quiero un trigger que actualice el campo updated_at en companies

DELIMITER //

CREATE TRIGGER update_company_updated_at
BEFORE UPDATE ON companies
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- 17. Como desarrollador, deseo un trigger que impida borrar una ciudad si hay empresas activas en ella.

DELIMITER //

CREATE TRIGGER prevent_deletion_of_city_with_active_companies
BEFORE DELETE ON citiesormunicipalities
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM companies WHERE city_id = OLD.code AND audience_id = 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete city with active companies';
    END IF;
END //

DELIMITER ;

-- 18. Como auditor, quiero un trigger que registre cambios de estado de encuestas.

DELIMITER //

CREATE TRIGGER log_poll_status_changes
AFTER UPDATE ON polls
FOR EACH ROW
BEGIN
    IF OLD.isactive != NEW.isactive THEN
        INSERT INTO log_acciones (message)
        VALUES (CONCAT('Poll status changed: ID ', NEW.id, ' - ', NEW.name, ' from ', 
                      CASE WHEN OLD.isactive = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END, 
                      ' to ', 
                      CASE WHEN NEW.isactive = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END,
                      ' at ', NOW()));
    END IF;
END //

DELIMITER ;

UPDATE polls SET isactive = FALSE WHERE id = 1;

-- 19. Como supervisor, deseo un trigger que sincronice rates con quality_products al calificar.

DELIMITER //

CREATE TRIGGER sync_rates_with_quality_products
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    -- Insertar o actualizar en quality_products
    INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
    SELECT cp.product_id, NEW.customer_id, NEW.poll_id, NEW.company_id, NEW.daterating, NEW.rating
    FROM companyproducts cp
    WHERE cp.company_id = NEW.company_id
    LIMIT 1
    ON DUPLICATE KEY UPDATE
        daterating = NEW.daterating,
        rating = NEW.rating;
END //

DELIMITER ;
    
-- 20. Como operador, quiero un trigger que elimine automáticamente productos sin relación a empresas.

DELIMITER //

CREATE TRIGGER delete_products_without_company_relation
AFTER DELETE ON companyproducts
FOR EACH ROW
BEGIN 
    DELETE FROM products 
    WHERE id = OLD.product_id 
    AND NOT EXISTS (
        SELECT 1 
        FROM companyproducts 
        WHERE product_id = OLD.product_id
    );
END //

DELIMITER ;
    

