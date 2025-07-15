-- Subconsultas

-- 1. Como gerente, quiero ver los productos cuyo precio esté por encima del promedio de su categoría.

SELECT p.name, p.price
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price > (SELECT AVG(price) FROM products WHERE category_id = c.id);

-- 2. Como administrador, deseo listar las empresas que tienen más productos que la media de empresas.

SELECT c.name
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.name
HAVING COUNT(cp.product_id) > (
    SELECT AVG(total_products) 
    FROM (
        SELECT company_id, COUNT(product_id) AS total_products 
    FROM companyproducts 
    GROUP BY company_id
    ) AS company_stats
);

-- 3. Como cliente, quiero ver mis productos favoritos que han sido calificados por otros clientes.

SELECT DISTINCT p.name, p.detail
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
WHERE f.customer_id = 1 
AND p.id IN (
    SELECT DISTINCT qp.product_id 
    FROM quality_products qp 
    WHERE qp.customer_id != 1
);

-- 4. Como supervisor, deseo obtener los productos con el mayor número de veces añadidos como favoritos.

SELECT p.name
FROM products p
JOIN details_favorites df ON p.id = df.product_id
GROUP BY p.id, p.name
HAVING COUNT(*) = (
    SELECT COUNT(*) AS total
    FROM details_favorites
    GROUP BY product_id
    ORDER BY total DESC
    LIMIT 1
);

-- 5. Como técnico, quiero listar los clientes cuyo correo no aparece en la tabla rates ni en quality_products.

SELECT c.name
FROM customers c
WHERE c.email NOT IN (
    SELECT DISTINCT customer_id 
    FROM rates
)
AND c.email NOT IN (
    SELECT DISTINCT customer_id 
    FROM quality_products
);

-- 6. Como gestor de calidad, quiero obtener los productos con una calificación inferior al mínimo de su categoría.

SELECT p.name
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN quality_products qp ON p.id = qp.product_id
WHERE qp.rating < (
    SELECT MIN(qp2.rating) 
    FROM quality_products qp2
    JOIN products p2 ON qp2.product_id = p2.id
    WHERE p2.category_id = c.id
);

-- 7. Como desarrollador, deseo listar las ciudades que no tienen clientes registrados.

SELECT cm.name 
FROM citiesormunicipalities cm
LEFT JOIN customers c ON cm.code = c.city_id
WHERE c.id IS NULL;

-- 8. Como administrador, quiero ver los productos que no han sido evaluados en ninguna encuesta.

SELECT p.name
FROM products p
LEFT JOIN quality_products qp ON p.id = qp.product_id
WHERE qp.product_id IS NULL;

-- 9. Como auditor, quiero listar los beneficios que no están asignados a ninguna audiencia.

SELECT b.description
FROM benefits b
LEFT JOIN audiencebenefits ab ON b.id = ab.benefit_id
WHERE ab.benefit_id IS NULL;

-- 10. Como cliente, deseo obtener mis productos favoritos que no están disponibles actualmente en ninguna empresa.

SELECT DISTINCT p.name
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
WHERE f.customer_id = 1 
AND p.id NOT IN (
    SELECT DISTINCT product_id 
    FROM companyproducts
);

-- 11. Como director, deseo consultar los productos vendidos en empresas cuya ciudad tenga menos de tres empresas registradas.

SELECT p.name
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN companies c ON cp.company_id = c.id
WHERE c.city_id IN (
    SELECT cm.code
    FROM citiesormunicipalities cm
    JOIN companies c ON cm.code = c.city_id
    GROUP BY cm.code
    HAVING COUNT(c.id) < 3
);

-- 12. Como analista, quiero ver los productos con calidad superior al promedio de todos los productos.

SELECT p.name
FROM products p 
JOIN quality_products qp ON p.id = qp.product_id
WHERE qp.rating > (
    SELECT AVG(qp2.rating) 
    FROM quality_products qp2
    JOIN products p2 ON qp2.product_id = p2.id
    WHERE p2.category_id = p.category_id
);

-- 13. Como gestor, quiero ver empresas que sólo venden productos de una única categoría.

SELECT c.name 
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT p.category_id) = 1;

-- 14. Como gerente comercial, quiero consultar los productos con el mayor precio entre todas las empresas.

SELECT p.name
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
WHERE cp.price = (
    SELECT MAX(cp2.price)
    FROM companyproducts cp2
    JOIN products p2 ON cp2.product_id = p2.id
);

-- 15. Como cliente, quiero saber si algún producto de mis favoritos ha sido calificado por otro cliente con más de 4 estrellas.

SELECT DISTINCT p.name
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
WHERE f.customer_id = 1
AND p.id IN (
    SELECT DISTINCT qp.product_id
    FROM quality_products qp
    WHERE qp.rating > 4
);

-- 16. Como operador, quiero saber qué productos no tienen imagen asignada pero sí han sido calificados.

SELECT p.name
FROM products p
WHERE p.image IS NULL
AND p.id IN (
    SELECT DISTINCT qp.product_id
    FROM quality_products qp
);

-- 17. Como auditor, quiero ver los planes de membresía sin periodo vigente.

SELECT m.name
FROM memberships m
LEFT JOIN membershipperiods mp ON m.id = mp.membership_id
WHERE mp.period_id IS NULL;

-- 18. Como especialista, quiero identificar los beneficios compartidos por más de una audiencia.

SELECT b.description
FROM benefits b
JOIN audiencebenefits ab ON b.id = ab.benefit_id
GROUP BY b.id, b.description
HAVING COUNT(DISTINCT ab.audience_id) > 1;

-- 19. Como técnico, quiero encontrar empresas cuyos productos no tengan unidad de medida definida.

SELECT c.name
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
WHERE cp.unitmeasure_id IS NULL;

-- 20. Como gestor de campañas, deseo obtener los clientes con membresía activa y sin productos favoritos.

SELECT c.name, m.name AS membership_name
FROM customers c
JOIN customer_memberships cm ON c.id = cm.customer_id
JOIN memberships m ON cm.membership_id = m.id
WHERE cm.isactive = 1
AND c.id NOT IN (
    SELECT DISTINCT customer_id
    FROM favorites
);

