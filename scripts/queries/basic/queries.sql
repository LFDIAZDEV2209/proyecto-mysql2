-- HISTORIAS DE USUARIO

-- 1. Como analista, quiero listar todos los productos con su empresa asociada y el precio mas bajo por ciudad.

SELECT p.name, c.name, MIN(cp.price) AS lowest_price
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN companies c ON cp.company_id = c.id
GROUP BY p.name, c.name;

-- 2. Como administrador, deseo obtener el top 5 de clientes que más productos han calificado en los últimos 6 meses.

SELECT c.name, COUNT(*) AS total_ratings
FROM customers c
JOIN rates r ON c.id = r.customer_id
WHERE r.daterating >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.name
ORDER BY total_ratings DESC
LIMIT 5;

-- 3. Como gerente de ventas, quiero ver la distribucion de productos por categoria y unidad de medida.

SELECT c.description, u.description, COUNT(*) AS total_products
FROM categories c
JOIN products p ON c.id = p.category_id
JOIN companyproducts cp ON p.id = cp.product_id
JOIN unitofmeasure u ON cp.unitmeasure_id = u.id
GROUP BY c.description, u.description
ORDER BY total_products DESC;

-- 4. Como cliente, quiero saber qué productos tienen calificaciones superiores al promedio general.

SELECT p.name, qp.rating
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
GROUP BY p.name, qp.rating
HAVING qp.rating > (SELECT AVG(rating) FROM quality_products)
ORDER BY qp.rating DESC;

-- 5. Como auditor, quiero conocer todas las empresas que no han recibido ninguna calificación. 

SELECT c.name
FROM companies c
LEFT JOIN rates r ON c.id = r.company_id
WHERE r.company_id IS NULL;

-- 6. Como operador, deseo obtener los productos que han sido añadidos como favoritos por más de 10 clientes distintos.

SELECT p.name, COUNT(DISTINCT f.customer_id) AS total_favorites
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
GROUP BY p.name
HAVING total_favorites > 10;

-- 7. Como gerente regional, quiero obtener todas las empresas activas por ciudad y categoría.

SELECT c.name, cm.name, ca.description
FROM companies c
JOIN citiesormunicipalities cm ON c.city_id = cm.code
JOIN categories ca ON c.category_id = ca.id
JOIN rates r ON c.id = r.company_id
JOIN polls p ON r.poll_id = p.id
WHERE p.isactive = 1
ORDER BY c.name DESC;

--8. Como especialista en marketing, deseo obtener los 10 productos más calificados en cada ciudad.

SELECT p.name, cm.name, qp.rating
FROM products p 
JOIN quality_products qp ON p.id = qp.product_id
JOIN companies c ON qp.company_id = c.id
JOIN citiesormunicipalities cm ON c.city_id = cm.code
GROUP BY p.name, cm.name, qp.rating
ORDER BY qp.rating DESC
LIMIT 10;

-- 9. Como técnico, quiero identificar productos sin unidad de medida asignada.

SELECT p.name
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
WHERE cp.unitmeasure_id IS NULL;

-- 10. Como gestor de beneficios, deseo ver los planes de membresía sin beneficios registrados.

SELECT m.name 
FROM memberships m
LEFT JOIN membershipbenefits mb ON m.id = mb.membership_id
WHERE mb.membership_id IS NULL;

-- 11. Como supervisor, quiero obtener los productos de una categoría específica con su promedio de calificación.

SELECT p.name, AVG(qp.rating) AS average_rating
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN categories c ON p.category_id = c.id
JOIN quality_products qp ON p.id = qp.product_id
WHERE c.description = 'Tecnología'
GROUP BY p.name, c.description;

-- 12. Como asesor, deseo obtener los clientes que han comprado productos de más de una empresa.

SELECT c.name
FROM customers c
JOIN quality_products qp ON c.id = qp.customer_id
JOIN products p ON qp.product_id = p.id
JOIN companyproducts cp ON p.id = cp.product_id
GROUP BY c.name
HAVING COUNT(DISTINCT cp.company_id) > 1;

-- 13. Como director, quiero identificar las ciudades con más clientes activos.

SELECT cm.name, COUNT(*) AS total_customers
FROM customers c 
JOIN citiesormunicipalities cm ON c.city_id = cm.code
JOIN rates r ON c.id = r.customer_id
JOIN polls p ON r.poll_id = p.id
WHERE p.isactive = 1
GROUP BY cm.name
ORDER BY total_customers DESC;

-- 14. Como analista de calidad, deseo obtener el ranking de productos por empresa basado en la media de quality_products.

SELECT p.name, c.name, AVG(qp.rating) AS average_rating
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
JOIN companies c ON qp.company_id = c.id
GROUP BY p.name, c.name
ORDER BY average_rating DESC;

-- 15. Como administrador, quiero listar empresas que ofrecen más de cinco productos distintos.

SELECT c.name, COUNT(DISTINCT cp.product_id) AS total_products
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.name
HAVING total_products > 5;

-- 16. Como cliente, deseo visualizar los productos favoritos que aún no han sido calificados.

SELECT p.name
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
LEFT JOIN quality_products qp ON p.id = qp.product_id
WHERE qp.product_id IS NULL
GROUP BY p.id, p.name;

-- 17. Como desarrollador, deseo consultar los beneficios asignados a cada audiencia junto con su descripción.

SELECT b.description, a.description
FROM benefits b
JOIN audiencebenefits ab ON b.id = ab.benefit_id
JOIN audiences a ON ab.audience_id = a.id;

-- 18. Como operador logístico, quiero saber en qué ciudades hay empresas sin productos asociados.

SELECT DISTINCT cm.name AS ciudad, c.name AS empresa
FROM citiesormunicipalities cm
JOIN companies c ON cm.code = c.city_id
LEFT JOIN companyproducts cp ON c.id = cp.company_id
WHERE cp.company_id IS NULL
ORDER BY cm.name, c.name;

-- 19. Como técnico, deseo obtener todas las empresas con productos duplicados por nombre.

SELECT c.name, p.name 
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
GROUP BY c.name, p.name
HAVING COUNT(*) > 1;

-- 20. Como analista, quiero una vista resumen de clientes, productos favoritos y promedio de calificación recibido.

SELECT c.name, p.name, AVG(qp.rating) AS average_rating
FROM customers c
JOIN favorites f ON c.id = f.customer_id
JOIN details_favorites df ON f.id = df.favorite_id
JOIN quality_products qp ON df.product_id = qp.product_id
JOIN products p ON df.product_id = p.id
GROUP BY c.name, p.name
ORDER BY average_rating DESC;



