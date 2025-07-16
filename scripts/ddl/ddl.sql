CREATE DATABASE IF NOT EXISTS proyecto;
USE proyecto;

CREATE TABLE countries (
    isocode VARCHAR(6) PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    alfasitwo VARCHAR(2) UNIQUE,
    alfasitothree VARCHAR(4) UNIQUE
);

CREATE TABLE stateregions (
    code VARCHAR(6) PRIMARY KEY,
    name VARCHAR(60) UNIQUE,
    country_id VARCHAR(6),
    code3166 VARCHAR(10) UNIQUE,
    subdivision_id INT(11),
    FOREIGN KEY (country_id) REFERENCES countries(isocode),
    FOREIGN KEY (subdivision_id) REFERENCES subdivisioncategories(id)
);

CREATE TABLE citiesormunicipalities (
    code VARCHAR(6) PRIMARY KEY,
    name VARCHAR(60) UNIQUE,
    statereg_id VARCHAR(6),
    FOREIGN KEY (statereg_id) REFERENCES stateregions(code)
);

CREATE TABLE subdivisioncategories (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(40) UNIQUE
);

CREATE TABLE typesofidentifications (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60),
    suffix VARCHAR(5) UNIQUE
);

CREATE TABLE unitofmeasure (
    id INT(11) PRIMARY KEY,
    description VARCHAR(60) UNIQUE
);

CREATE TABLE categories (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60) UNIQUE
);

CREATE TABLE audiences (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60),
    isactive BOOLEAN
);

CREATE TABLE companies (
    id VARCHAR(20) PRIMARY KEY,
    type_id INT(11),
    name VARCHAR(80),
    category_id INT(11),
    city_id VARCHAR(6),
    audience_id INT(11),
    cellphone VARCHAR(15),
    email VARCHAR(80),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES typesofidentifications(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(code),
    FOREIGN KEY (audience_id) REFERENCES audiences(id)
);

CREATE TABLE customers (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80),
    city_id VARCHAR(6),
    audience_id INT(11),
    cellphone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(120),
    FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(code),
    FOREIGN KEY (audience_id) REFERENCES audiences(id)
);

CREATE TABLE products (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(60),
    detail TEXT,
    price DOUBLE(10,2),
    category_id INT(11),
    image VARCHAR(80),
    average_rating DOUBLE(10,2) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE companyproducts (
    company_id VARCHAR(20),
    product_id INT(11),
    price DOUBLE(10,2),
    unitmeasure_id INT(11),
    PRIMARY KEY (company_id, product_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (unitmeasure_id) REFERENCES unitofmeasure(id)
);

CREATE TABLE favorites (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    company_id VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE details_favorites (
    id INT(11) PRIMARY KEY,
    favorite_id INT(11),
    product_id INT(11),
    FOREIGN KEY (favorite_id) REFERENCES favorites(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE quality_products (
    product_id INT(11),
    customer_id INT(11),
    poll_id INT(11),
    company_id VARCHAR(20),
    daterating DATETIME,
    rating DOUBLE(10,2),
    PRIMARY KEY (product_id, customer_id, poll_id, company_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (poll_id) REFERENCES polls(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE polls (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) UNIQUE,
    description TEXT,
    isactive BOOLEAN,
    categorypoll_id INT(11),
    FOREIGN KEY (categorypoll_id) REFERENCES categories(id)
);

CREATE TABLE memberships (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE,
    description TEXT
);

CREATE TABLE periods (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE
);

CREATE TABLE membershipperiods (
    membership_id INT(11),
    period_id INT(11),
    price DOUBLE(10,2),
    PRIMARY KEY (membership_id, period_id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id),
    FOREIGN KEY (period_id) REFERENCES periods(id)
);

CREATE TABLE benefits (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(80),
    detail TEXT
);

CREATE TABLE membershipbenefits (
    membership_id INT(11),
    period_id INT(11),
    audience_id INT(11),
    benefit_id INT(11),
    PRIMARY KEY (membership_id, period_id, audience_id, benefit_id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id),
    FOREIGN KEY (period_id) REFERENCES periods(id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(id)
);

CREATE TABLE audiencebenefits (
    audience_id INT(11),
    benefit_id INT(11),
    PRIMARY KEY (audience_id, benefit_id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(id)
);

CREATE TABLE categories_polls (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) UNIQUE
);

CREATE TABLE rates (
    customer_id INT(11),
    company_id VARCHAR(20),
    poll_id INT(11),
    daterating DATETIME,
    rating DOUBLE(10,2),
    PRIMARY KEY (customer_id, company_id, poll_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (poll_id) REFERENCES polls(id)
);

CREATE TABLE customer_memberships (
    customer_id INT(11),
    membership_id INT(11),
    start_date DATE,
    end_date DATE,
    isactive BOOLEAN,
    PRIMARY KEY (customer_id, membership_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id)
);

CREATE TABLE resumen_calificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id VARCHAR(20),
    mes INT,
    año INT,
    promedio_calificacion DOUBLE(10,2),
    total_calificaciones INT,
    fecha_generacion DATETIME,
    FOREIGN KEY (empresa_id) REFERENCES companies(id)
);

CREATE TABLE errores_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    error_message TEXT,
    error_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE poll_questions (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    poll_id INT(11),
    question_text TEXT,
    FOREIGN KEY (poll_id) REFERENCES polls(id)
);

CREATE TABLE historial_precios (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    product_id INT(11),
    old_price DOUBLE(10,2),
    new_price DOUBLE(10,2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE log_acciones (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    message TEXT,
    date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    message TEXT,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS product_metrics (
    product_id INT(11) PRIMARY KEY,
    average_rating DOUBLE(10,2) DEFAULT NULL,
    total_ratings INT DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS favoritos_resumen (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    total_favoritos INT,
    fecha_calculo DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS inconsistencias_fk (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_origen VARCHAR(50),
    campo_origen VARCHAR(50),
    valor_origen VARCHAR(50),
    tabla_referencia VARCHAR(50),
    fecha_deteccion DATETIME DEFAULT CURRENT_TIMESTAMP
);