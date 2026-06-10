-- ============================================================================
-- PURPOSE:
--   Consolidated DDL script to initialize the complete Silver Layer.
--   This script creates all transformed, cleansed, and standardized tables
--   derived from the Bronze layer source data.
--
-- TARGET DATA WAREHOUSE LAYER:
--   Silver (Cleansed / Conformed Integration Zone)
--
-- WARNING:
--   - Ensure the 'silver' schema has been successfully created before execution.
--   - Execute this script only after the Bronze layer has been successfully
--     loaded and validated.
--   - 'IF NOT EXISTS' is applied to every table to allow safe, repeatable
--     execution across all deployment environments (Dev, QA, Prod).
-- ============================================================================

------------------------------------------------------------------------------
-- SECTION 1: CRM SYSTEM TABLES
------------------------------------------------------------------------------

-- Table 1: Customer Master Info
CREATE TABLE IF NOT EXISTS silver.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE silver.crm_cust_info IS
'Cleansed and standardized CRM customer master data enriched for downstream analytics and reporting.';

-- Table 2: Product Master Info
CREATE TABLE IF NOT EXISTS silver.crm_prd_info (
    prd_id       INTEGER,
	cat_id		 VARCHAR(50),
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INTEGER,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
COMMENT ON TABLE silver.crm_prd_info IS
'Cleansed CRM product master data containing standardized product attributes and historical product information.';

-- Table 3: Sales Transaction Details
CREATE TABLE IF NOT EXISTS silver.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt DATE,  -- Format: YYYYMMDD
    sls_ship_dt  DATE,  -- Format: YYYYMMDD
    sls_due_dt   DATE,  -- Format: YYYYMMDD
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
COMMENT ON TABLE silver.crm_sales_details IS
'Cleansed and validated CRM sales transaction data prepared for business analysis and dimensional modeling.';

------------------------------------------------------------------------------
-- SECTION 2: ERP SYSTEM TABLES
------------------------------------------------------------------------------

-- Table 4: Location Mapping
CREATE TABLE IF NOT EXISTS silver.erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE silver.erp_loc_a101 IS
'Standardized ERP location reference data containing customer country and geographic mappings.';

-- Table 5: Customer Demographics
CREATE TABLE IF NOT EXISTS silver.erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE silver.erp_cust_az12 IS
'Cleansed ERP customer demographic data containing standardized birthdate and gender attributes.';

-- Table 6: Product Category Hierarchy
CREATE TABLE IF NOT EXISTS silver.erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE silver.erp_px_cat_g1v2 IS
'Standardized ERP product category hierarchy containing product category and subcategory reference data.';
-- ============================================================================
-- END OF CONSOLIDATED silver LAYER SCRIPT
-- ============================================================================