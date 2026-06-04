-- ============================================================================
-- PURPOSE:
--   Consolidated DDL script to initialize the complete Bronze Ingestion Layer.
--   This script creates all 6 raw source tables across the CRM and ERP systems.
--
-- TARGET DATA WAREHOUSE LAYER: 
--   Bronze (Raw / Immutable Ingestion Zone)
--
-- WARNING:
--   - Ensure the 'bronze' schema has been successfully created before execution.
--   - 'IF NOT EXISTS' is applied to every table to allow safe, repeatable 
--     execution across all deployment environments (Dev, QA, Prod).
-- ============================================================================

------------------------------------------------------------------------------
-- SECTION 1: CRM SOURCE SYSTEM TABLES
------------------------------------------------------------------------------

-- Table 1: Customer Master Info
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);
COMMENT ON TABLE bronze.crm_cust_info IS 'Raw ingestion table for CRM customer master records.';


-- Table 2: Product Master Info
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
    prd_id       INTEGER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INTEGER,
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt   TIMESTAMP
);
COMMENT ON TABLE bronze.crm_prd_info IS 'Raw ingestion table for CRM product catalogs and history.';


-- Table 3: Sales Transaction Details
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt INTEGER,  -- Format: YYYYMMDD
    sls_ship_dt  INTEGER,  -- Format: YYYYMMDD
    sls_due_dt   INTEGER,  -- Format: YYYYMMDD
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER
);
COMMENT ON TABLE bronze.crm_sales_details IS 'Raw ingestion table for CRM transactional sales details.';


------------------------------------------------------------------------------
-- SECTION 2: ERP SOURCE SYSTEM TABLES
------------------------------------------------------------------------------

-- Table 4: Location Mapping
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50)
);
COMMENT ON TABLE bronze.erp_loc_a101 IS 'Raw ERP extract: Location and country lookup codes (Source: A101).';


-- Table 5: Customer Demographics
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);
COMMENT ON TABLE bronze.erp_cust_az12 IS 'Raw ERP extract: Customer core demographics, birthdates, and gender (Source: AZ12).';


-- Table 6: Product Category Hierarchy
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50)
);
COMMENT ON TABLE bronze.erp_px_cat_g1v2 IS 'Raw ERP extract: Product category and subcategory structural hierarchy (Source: G1V2).';

-- ============================================================================
-- END OF CONSOLIDATED BRONZE LAYER SCRIPT
-- ============================================================================
