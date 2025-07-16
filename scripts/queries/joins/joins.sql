-- Historias de Usuario con JOINs

-- 1. Como analista, quiero consultar todas las empresas junto con los productos que ofrecen, mostrando el nombre del producto y el precio.
SELECT 
    c.name,
    p.name,
    cp.price
FROM companies c
INNER JOIN companyproducts cp ON c.id = cp.company_id
INNER JOIN products p ON cp.product_id = p.id
ORDER BY c.name, p.name;

-- 2. Mostrar productos favoritos con su empresa y categoría
SELECT 
    p.name,
    c.name,
    cat.description
FROM customers cu
INNER JOIN favorites f ON cu.id = f.customer_id
INNER JOIN details_favorites df ON f.id = df.favorite_id
INNER JOIN products p ON df.product_id = p.id
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
INNER JOIN categories cat ON p.category_id = cat.id
ORDER BY cu.name, p.name;

-- 3. Ver empresas aunque no tengan productos
SELECT 
    c.name,
    c.email,
    COUNT(cp.product_id)
FROM companies c
LEFT JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.id, c.name, c.email
ORDER BY COUNT(cp.product_id) DESC, c.name;

-- 4. Ver productos que fueron calificados (o no)
SELECT 
    p.name,
    p.detail,
    qp.rating,
    qp.daterating
FROM quality_products qp
RIGHT JOIN products p ON qp.product_id = p.id
ORDER BY p.name;

-- 5. Ver productos con promedio de calificación y empresa
SELECT 
    p.name,
    c.name,
    ROUND(AVG(qp.rating), 2),
    COUNT(qp.rating)
FROM products p
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
LEFT JOIN quality_products qp ON p.id = qp.product_id
GROUP BY p.id, p.name, c.id, c.name
ORDER BY AVG(qp.rating) DESC, p.name;

-- 6. Ver clientes y sus calificaciones (si las tienen)
SELECT 
    cu.name,
    cu.email,
    r.rating,
    r.daterating,
    c.name
FROM customers cu
LEFT JOIN rates r ON cu.id = r.customer_id
LEFT JOIN companies c ON r.company_id = c.id
ORDER BY cu.name, r.daterating DESC;

-- 7. Ver favoritos con la última calificación del cliente
SELECT 
    cu.name,
    p.name,
    c.name,
    qp.rating,
    qp.daterating
FROM customers cu
INNER JOIN favorites f ON cu.id = f.customer_id
INNER JOIN details_favorites df ON f.id = df.favorite_id
INNER JOIN products p ON df.product_id = p.id
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
LEFT JOIN quality_products qp ON p.id = qp.product_id 
    AND cu.id = qp.customer_id
    AND qp.daterating = (
        SELECT MAX(qp2.daterating) 
        FROM quality_products qp2 
        WHERE qp2.product_id = p.id AND qp2.customer_id = cu.id
    )
ORDER BY cu.name, p.name;

-- 8. Ver beneficios incluidos en cada plan de membresía
SELECT 
    m.name,
    m.description,
    b.description,
    b.detail
FROM memberships m
INNER JOIN membershipbenefits mb ON m.id = mb.membership_id
INNER JOIN benefits b ON mb.benefit_id = b.id
ORDER BY m.name, b.description;

-- 9. Ver clientes con membresía activa y sus beneficios
SELECT 
    cu.name,
    cu.email,
    m.name,
    cm.start_date,
    cm.end_date,
    b.description,
    b.detail
FROM customers cu
INNER JOIN customer_memberships cm ON cu.id = cm.customer_id
INNER JOIN memberships m ON cm.membership_id = m.id
INNER JOIN membershipbenefits mb ON m.id = mb.membership_id
INNER JOIN benefits b ON mb.benefit_id = b.id
WHERE cm.isactive = 1 
    AND CURDATE() BETWEEN cm.start_date AND cm.end_date
ORDER BY cu.name, m.name, b.description;

-- 10. Ver ciudades con cantidad de empresas
SELECT 
    ci.name,
    sr.name,
    co.name,
    COUNT(c.id)
FROM citiesormunicipalities ci
LEFT JOIN companies c ON ci.code = c.city_id
LEFT JOIN stateregions sr ON ci.statereg_id = sr.code
LEFT JOIN countries co ON sr.country_id = co.isocode
GROUP BY ci.code, ci.name, sr.name, co.name
ORDER BY COUNT(c.id) DESC, ci.name;

-- 11. Ver encuestas con calificaciones
SELECT 
    p.name,
    p.description,
    r.rating,
    r.daterating,
    c.name,
    cu.name
FROM polls p
INNER JOIN rates r ON p.id = r.poll_id
INNER JOIN companies c ON r.company_id = c.id
INNER JOIN customers cu ON r.customer_id = cu.id
WHERE p.isactive = 1
ORDER BY p.name, r.daterating DESC;

-- 12. Ver productos evaluados con datos del cliente
SELECT 
    p.name,
    p.detail,
    cu.name,
    cu.email,
    qp.rating,
    qp.daterating,
    c.name
FROM quality_products qp
INNER JOIN products p ON qp.product_id = p.id
INNER JOIN customers cu ON qp.customer_id = cu.id
INNER JOIN companies c ON qp.company_id = c.id
ORDER BY qp.daterating DESC, p.name;

-- 13. Ver productos con audiencia de la empresa
SELECT 
    p.name,
    p.detail,
    c.name,
    a.description,
    cat.description
FROM products p
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
INNER JOIN audiences a ON c.audience_id = a.id
INNER JOIN categories cat ON p.category_id = cat.id
WHERE a.isactive = 1
ORDER BY a.description, c.name, p.name;

-- 14. Ver clientes con sus productos favoritos
SELECT 
    cu.name,
    cu.email,
    p.name,
    c.name,
    f.id
FROM customers cu
INNER JOIN favorites f ON cu.id = f.customer_id
INNER JOIN details_favorites df ON f.id = df.favorite_id
INNER JOIN products p ON df.product_id = p.id
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
ORDER BY cu.name, p.name;

-- 15. Ver planes, periodos, precios y beneficios
SELECT 
    m.name,
    m.description,
    per.name,
    mp.price,
    b.description,
    b.detail
FROM memberships m
INNER JOIN membershipperiods mp ON m.id = mp.membership_id
INNER JOIN periods per ON mp.period_id = per.id
INNER JOIN membershipbenefits mb ON m.id = mb.membership_id AND mp.period_id = mb.period_id
INNER JOIN benefits b ON mb.benefit_id = b.id
ORDER BY m.name, per.name, b.description;

-- 16. Ver combinaciones empresa-producto-cliente calificados
SELECT 
    c.name,
    p.name,
    cu.name,
    cu.email,
    qp.rating,
    qp.daterating,
    pol.name
FROM quality_products qp
INNER JOIN companies c ON qp.company_id = c.id
INNER JOIN products p ON qp.product_id = p.id
INNER JOIN customers cu ON qp.customer_id = cu.id
INNER JOIN polls pol ON qp.poll_id = pol.id
ORDER BY c.name, p.name, qp.daterating DESC;

-- 17. Comparar favoritos con productos calificados
SELECT 
    cu.name,
    p.name,
    c.name,
    qp.rating,
    qp.daterating
FROM customers cu
INNER JOIN favorites f ON cu.id = f.customer_id
INNER JOIN details_favorites df ON f.id = df.favorite_id
INNER JOIN products p ON df.product_id = p.id
INNER JOIN companyproducts cp ON p.id = cp.product_id
INNER JOIN companies c ON cp.company_id = c.id
INNER JOIN quality_products qp ON p.id = qp.product_id AND cu.id = qp.customer_id
ORDER BY cu.name, p.name;

-- 18. Ver productos ordenados por categoría
SELECT 
    cat.description,
    p.name,
    p.detail,
    p.price,
    COUNT(cp.company_id)
FROM categories cat
INNER JOIN products p ON cat.id = p.category_id
LEFT JOIN companyproducts cp ON p.id = cp.product_id
GROUP BY cat.id, cat.description, p.id, p.name, p.detail, p.price
ORDER BY cat.description, p.name;

-- 19. Ver beneficios por audiencia, incluso vacíos
SELECT 
    a.description,
    a.isactive,
    b.description,
    b.detail
FROM audiences a
LEFT JOIN audiencebenefits ab ON a.id = ab.audience_id
LEFT JOIN benefits b ON ab.benefit_id = b.id
ORDER BY a.description, b.description;

-- 20. Ver datos cruzados entre calificaciones, encuestas, productos y clientes
SELECT 
    cu.name,
    cu.email,
    p.name,
    c.name,
    pol.name,
    pol.description,
    qp.rating,
    qp.daterating,
    cat.description
FROM quality_products qp
INNER JOIN customers cu ON qp.customer_id = cu.id
INNER JOIN products p ON qp.product_id = p.id
INNER JOIN companies c ON qp.company_id = c.id
INNER JOIN polls pol ON qp.poll_id = pol.id
INNER JOIN categories cat ON p.category_id = cat.id
ORDER BY qp.daterating DESC, cu.name, p.name;
