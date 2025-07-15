-- Funciones agregadas

-- 1. Como analista, quiero obtener el promedio de calificación por producto.

SELECT p.name, AVG(qp.rating) AS average_rating
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
GROUP BY p.id, p.name;

-- 2. Como gerente, desea contar cuántos productos ha calificado cada cliente.

SELECT c.name, COUNT(DISTINCT qp.product_id) AS total_products_rated
FROM customers c
JOIN quality_products qp ON c.id = qp.customer_id
GROUP BY c.id, c.name;

-- 3. Como auditor, quiere sumar el total de beneficios asignados por audiencia.

SELECT a.description, COUNT(DISTINCT b.id) AS total_benefits
FROM audiences a
LEFT JOIN audiencebenefits ab ON a.id = ab.audience_id
LEFT JOIN benefits b ON ab.benefit_id = b.id
GROUP BY a.id, a.description
ORDER BY total_benefits DESC;

-- 4. Como administrador, desea conocer la media de productos por empresa.

SELECT c.name, COUNT(cp.product_id) AS total_products
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.id, c.name
HAVING COUNT(cp.product_id) > (
    SELECT AVG(product_count) 
    FROM (
        SELECT COUNT(cp2.product_id) AS product_count
        FROM companies c2
        JOIN companyproducts cp2 ON c2.id = cp2.company_id
        GROUP BY c2.id
    ) AS company_products_avg
);

-- 5. Como supervisor, quiere ver el total de empresas por ciudad.

SELECT cm.name, COUNT(c.id) AS total_companies
FROM citiesormunicipalities cm
JOIN companies c ON cm.code = c.city_id
GROUP BY cm.name;

-- 6. Como técnico, desea obtener el promedio de precios de productos por unidad de medida.

SELECT um.description, AVG(cp.price) AS average_price
FROM unitofmeasure um
JOIN companyproducts cp ON um.id = cp.unitmeasure_id
GROUP BY um.id, um.description;

-- 7. Como gerente, quiere ver el número de clientes registrados por cada ciudad.

SELECT cm.name, COUNT(c.id) AS total_customers
FROM citiesormunicipalities cm
JOIN customers c ON cm.code = c.city_id
GROUP BY cm.name;

-- 8. Como operador, desea contar cuántos planes de membresía existen por periodo.

SELECT p.name, COUNT(mp.membership_id) AS total_memberships
FROM periods p
JOIN membershipperiods mp ON p.id = mp.period_id
GROUP BY p.id, p.name;

-- 9. Como cliente, quiere ver el promedio de calificaciones que ha otorgado a sus productos favoritos.

SELECT AVG(qp.rating) AS average_rating
FROM quality_products qp
JOIN details_favorites df ON qp.product_id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
JOIN customers c ON f.customer_id = c.id
GROUP BY c.id, c.name;

-- 10. Como auditor, desea obtener la fecha más reciente en la que se calificó un producto.

SELECT MAX(qp.daterating) AS latest_rating
FROM quality_products qp;

-- 11. Como desarrollador, quiere conocer la variación de precios por categoría de producto.

SELECT c.description, STDDEV(cp.price) AS price_variation
FROM categories c
JOIN products p ON c.id = p.category_id
JOIN companyproducts cp ON p.id = cp.product_id
GROUP BY c.id, c.description;

-- 12. Como técnico, desea contar cuántas veces un producto fue marcado como favorito.

SELECT p.name, COUNT(f.id) AS total_favorites
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
GROUP BY p.id, p.name;
--SI QUIERE DE UNO SOLO SIMPLEMENTE SE AGREGA UN LIMIT 1

-- 13. Como director, quiere saber qué porcentaje de productos han sido calificados al menos una vez.

SELECT COUNT(DISTINCT qp.product_id) / COUNT(DISTINCT p.id) * 100 AS percentage_rated
FROM products p
JOIN quality_products qp ON p.id = qp.product_id;

-- 14. Como analista, desea conocer el promedio de rating por encuesta.

SELECT p.name, AVG(r.rating) AS average_rating
FROM polls p
JOIN rates r ON p.id = r.poll_id
GROUP BY p.id, p.name;

-- 15. Como gestor, quiere obtener el promedio y el total de beneficios asignados a cada plan de membresía.

SELECT m.name, 
       COUNT(DISTINCT mb.benefit_id) AS total_benefits,
       COUNT(DISTINCT mb.audience_id) AS total_audiences
FROM memberships m
LEFT JOIN membershipbenefits mb ON m.id = mb.membership_id
GROUP BY m.id, m.name
ORDER BY total_benefits DESC;

-- 16. Como gerente, desea obtener la media y la varianza del precio de productos por empresa.

SELECT c.name, AVG(cp.price) AS average_price, VARIANCE(cp.price) AS price_variance
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.id, c.name;

-- 17. Como cliente, quiere ver cuántos productos están disponibles en su ciudad.

SELECT cm.name, COUNT(p.id) AS total_products
FROM citiesormunicipalities cm 
JOIN companies c ON cm.code = c.city_id
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
GROUP BY cm.name;

-- 18. Como administrador, desea contar los productos únicos por tipo de empresa.

SELECT c.type_id, COUNT(DISTINCT p.id) AS total_products
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
GROUP BY c.type_id;

-- 19. Como operador, quiere saber cuántos clientes no han registrado su correo.

SELECT COUNT(c.id) AS total_customers
FROM customers c
WHERE c.email IS NULL;

-- 20. Como especialista, desea obtener la empresa con el mayor número de productos calificados.

SELECT c.name, COUNT(DISTINCT qp.product_id) AS total_products_rated
FROM companies c
JOIN quality_products qp ON c.id = qp.company_id
GROUP BY c.id, c.name
ORDER BY total_products_rated DESC
LIMIT 1;






