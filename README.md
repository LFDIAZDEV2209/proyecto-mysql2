# 🗄️ Proyecto MySQL2 - Sistema de Gestión de Productos y Calificaciones

[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![SQL](https://img.shields.io/badge/SQL-Query-336791?style=for-the-badge&logo=sql&logoColor=white)](https://www.sql.org/)
[![Database](https://img.shields.io/badge/Database-Management-336791?style=for-the-badge&logo=database&logoColor=white)](https://en.wikipedia.org/wiki/Database)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Author-LFDIAZDEV2209-blue?style=for-the-badge)](https://github.com/LFDIAZDEV2209)

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema completo de gestión de productos, empresas, clientes y calificaciones utilizando MySQL. El sistema incluye funcionalidades avanzadas como triggers, procedimientos almacenados, funciones personalizadas, eventos programados y consultas complejas.

## 🏗️ Arquitectura del Sistema

### 📊 Estructura de Base de Datos

El sistema está compuesto por las siguientes entidades principales:

- **🌍 Geografía**: `countries`, `stateregions`, `citiesormunicipalities`
- **🏢 Empresas**: `companies`, `companyproducts`
- **👥 Clientes**: `customers`, `favorites`, `details_favorites`
- **📦 Productos**: `products`, `categories`, `unitofmeasure`
- **⭐ Calificaciones**: `quality_products`, `rates`, `polls`
- **🎯 Membresías**: `memberships`, `customer_memberships`, `benefits`
- **📊 Auditoría**: `resumen_calificaciones`, `errores_log`, `notifications`

## 📁 Estructura del Proyecto

```
proyecto-mysql2/
├── 📚 docs/                          # Documentación y archivos de referencia
│   ├── CodigosIso.xlsx
│   ├── colombia_city_codes.csv
│   ├── colombia_city_codes.xlsx
│   ├── divipola_dane.pdf
│   ├── isoDep.xlsx
│   ├── Listado_Codigos_Paises.docx
│   └── Paises_2009.pdf
├── 📜 scripts/                       # Scripts SQL organizados por categoría
│   ├── 🏗️ ddl/                      # Definición de estructura
│   │   └── ddl.sql
│   ├── 📥 dml/                      # Datos de prueba
│   │   └── inserts.sql
│   ├── ⏰ events/                   # Eventos programados
│   │   └── events.sql
│   ├── ⚙️ functions/               # Funciones personalizadas
│   │   └── functions.sql
│   ├── 🔧 procedures/              # Procedimientos almacenados
│   │   └── procedures.sql
│   ├── 🔍 queries/                 # Consultas SQL
│   │   ├── 📈 advanced/           # Funciones agregadas
│   │   │   └── agg-funct.sql
│   │   ├── 🔰 basic/              # Consultas básicas
│   │   │   └── queries.sql
│   │   ├── 🔗 intermediate/       # Subconsultas
│   │   │   └── subqueries.sql
│   │   └── 🔗 joins/              # Consultas con JOINs
│   │       └── joins.sql
│   └── ⚡ triggers/               # Triggers
│       └── triggers.sql
└── 📖 README.md
```

## 🚀 Características Principales

### 🎯 Funcionalidades Implementadas

- ✅ **Gestión Completa de Productos y Empresas**
- ✅ **Sistema de Calificaciones y Encuestas**
- ✅ **Manejo de Favoritos y Membresías**
- ✅ **Triggers para Validación y Auditoría**
- ✅ **Procedimientos Almacenados para Operaciones Complejas**
- ✅ **Funciones Personalizadas para Cálculos Especializados**
- ✅ **Eventos Programados para Mantenimiento Automático**
- ✅ **Consultas Avanzadas con JOINs y Subconsultas**
- ✅ **Sistema de Notificaciones y Logs**

### 🔧 Componentes Técnicos

#### 📊 **20 Funciones Personalizadas**
- Cálculo de promedios ponderados
- Validación de membresías activas
- Generación de códigos únicos
- Análisis de popularidad de productos

#### ⚡ **20 Triggers**
- Validación de integridad de datos
- Actualización automática de promedios
- Prevención de duplicados
- Logging de acciones importantes

#### 🔧 **20 Procedimientos Almacenados**
- Registro de calificaciones
- Gestión de empresas y productos
- Generación de reportes mensuales
- Mantenimiento de datos

#### ⏰ **20 Eventos Programados**
- Limpieza automática de datos inactivos
- Recalculación de promedios
- Actualización de precios por inflación
- Generación de backups lógicos

#### 🔍 **80+ Consultas SQL**
- Consultas básicas de selección
- Consultas con JOINs complejos
- Subconsultas anidadas
- Funciones agregadas avanzadas

## 🛠️ Instalación y Configuración

### 📋 Prerrequisitos

- MySQL 8.0 o superior
- Cliente MySQL (MySQL Workbench, phpMyAdmin, etc.)
- Permisos de administrador para crear bases de datos

### 🔧 Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/LFDIAZDEV2209/proyecto-mysql2.git
   cd proyecto-mysql2
   ```

2. **Ejecutar scripts en orden**
   ```sql
   -- 1. Crear estructura de base de datos
   SOURCE scripts/ddl/ddl.sql;
   
   -- 2. Insertar datos de prueba
   SOURCE scripts/dml/inserts.sql;
   
   -- 3. Crear funciones personalizadas
   SOURCE scripts/functions/functions.sql;
   
   -- 4. Crear procedimientos almacenados
   SOURCE scripts/procedures/procedures.sql;
   
   -- 5. Crear triggers
   SOURCE scripts/triggers/triggers.sql;
   
   -- 6. Crear eventos programados
   SOURCE scripts/events/events.sql;
   ```

3. **Verificar instalación**
   ```sql
   USE proyecto;
   SHOW TABLES;
   SELECT COUNT(*) FROM products;
   ```

## 📖 Guía de Uso

### 🔍 Ejemplos de Consultas

#### Consulta Básica - Productos por Empresa
```sql
SELECT p.name, c.name, cp.price
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN companies c ON cp.company_id = c.id
ORDER BY c.name, p.name;
```

#### Función Personalizada - Promedio Ponderado
```sql
SELECT p.name, calcular_promedio_ponderado(p.id) as promedio_ponderado
FROM products p
WHERE p.id = 1;
```

#### Procedimiento - Registrar Calificación
```sql
CALL RegisterRating(1, 1, 4.5);
```

### 🎯 Casos de Uso Principales

1. **Gestión de Productos**
   - Registro de productos con categorías
   - Asociación con empresas
   - Control de precios y unidades de medida

2. **Sistema de Calificaciones**
   - Evaluación de productos por clientes
   - Cálculo automático de promedios
   - Generación de reportes de calidad

3. **Gestión de Clientes**
   - Registro de clientes con ubicación
   - Sistema de favoritos
   - Membresías y beneficios

4. **Auditoría y Reportes**
   - Logs automáticos de acciones
   - Resúmenes mensuales
   - Validación de integridad de datos

## 📊 Estructura de Datos

### 🔗 Relaciones Principales

```
customers (1:N) favorites (1:N) details_favorites (N:1) products
companies (1:N) companyproducts (N:1) products
products (1:N) quality_products (N:1) customers
customers (1:N) customer_memberships (N:1) memberships
```

### 📈 Tablas de Auditoría

- `resumen_calificaciones`: Resúmenes mensuales por empresa
- `errores_log`: Registro de errores del sistema
- `notifications`: Sistema de notificaciones
- `log_acciones`: Log de acciones importantes

## 🔧 Mantenimiento

### ⏰ Eventos Automáticos

El sistema incluye eventos programados para:

- **Limpieza mensual**: Eliminación de productos inactivos
- **Recálculo semanal**: Actualización de promedios de calificación
- **Actualización de precios**: Ajuste por inflación mensual
- **Backup diario**: Respaldo lógico de datos críticos

### 📊 Monitoreo

```sql
-- Verificar eventos activos
SHOW EVENTS;

-- Revisar logs de errores
SELECT * FROM errores_log ORDER BY error_date DESC;

-- Verificar inconsistencias
SELECT * FROM inconsistencias_fk;
```

## 🤝 Contribución

### 📝 Guías de Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### 🐛 Reporte de Bugs

Si encuentras un bug, por favor:

1. Revisa los issues existentes
2. Crea un nuevo issue con:
   - Descripción detallada del problema
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Información del entorno

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**LFDIAZDEV2209**

- GitHub: [@LFDIAZDEV2209](https://github.com/LFDIAZDEV2209)
- LinkedIn: [LFDIAZDEV2209](https://linkedin.com/in/LFDIAZDEV2209)

## 🙏 Agradecimientos

- MySQL Community por la excelente documentación
- Stack Overflow por las soluciones compartidas
- La comunidad de desarrolladores SQL

## 📞 Contacto

Si tienes preguntas o sugerencias sobre este proyecto:

- 📧 Email: lfdiazdev2209@gmail.com
- 🐦 Twitter: [@LFDIAZDEV2209](https://twitter.com/LFDIAZDEV2209)
- 💼 LinkedIn: [LFDIAZDEV2209](https://linkedin.com/in/LFDIAZDEV2209)

---

<div align="center">

**⭐ Si este proyecto te ha sido útil, considera darle una estrella en GitHub! ⭐**

</div>
