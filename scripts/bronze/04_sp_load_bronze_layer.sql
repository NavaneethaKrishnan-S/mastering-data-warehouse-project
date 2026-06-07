/*

Procedure Name : bronze.load_bronze_layer
Project : Data Warehouse
Layer : Bronze

Purpose: Loads raw CSV files into Bronze layer tables.

Source Files:
source_crm/cust_info.csv
source_crm/prd_info.csv
source_crm/sales_details.csv
source_erp/cust_az12.csv
source_erp/loc_a101.csv
source_erp/px_cat_g1v2.csv

Process:
1. Truncate existing Bronze tables.
2. Load fresh data from CSV files.
3. Display row counts and load duration for verification.

Warning:
1. Source files must exist on the PostgreSQL server.
2. PostgreSQL service account must have read permissions.
3. Existing data will be permanently deleted before reload.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze_layer()
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_count BIGINT;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;

	v_load_start_time TIMESTAMP;
    v_load_end_time TIMESTAMP;

BEGIN

	v_load_start_time := clock_timestamp();

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Starting Bronze Layer Load';
    RAISE NOTICE '===========================================';

    ---------------------------------------------------------------------------
    -- CRM CUSTOMER INFO
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.crm_cust_info';
        COPY bronze.crm_cust_info
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_crm\cust_info.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.crm_cust_info;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'crm_cust_info loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.crm_cust_info';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- CRM PRODUCT INFO
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.crm_prd_info';
        COPY bronze.crm_prd_info
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_crm\prd_info.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.crm_prd_info;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'crm_prd_info loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.crm_prd_info';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- CRM SALES DETAILS
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.crm_sales_details';
        COPY bronze.crm_sales_details
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_crm\sales_details.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.crm_sales_details;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'crm_sales_details loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.crm_sales_details';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP CUSTOMER
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.erp_cust_az12';
        COPY bronze.erp_cust_az12
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_erp\cust_az12.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.erp_cust_az12;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'erp_cust_az12 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.erp_cust_az12';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP LOCATION
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.erp_loc_a101';
        COPY bronze.erp_loc_a101
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_erp\loc_a101.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.erp_loc_a101;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'erp_loc_a101 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.erp_loc_a101';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP PRODUCT CATEGORY
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        RAISE NOTICE 'INSERTING DATA INTO: bronze.erp_px_cat_g1v2';
        COPY bronze.erp_px_cat_g1v2
        FROM 'C:\Program Files\PostgreSQL\18\data\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ','
        );

        SELECT COUNT(*)
        INTO v_row_count
        FROM bronze.erp_px_cat_g1v2;

        v_end_time := clock_timestamp();

        RAISE NOTICE 'erp_px_cat_g1v2 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: bronze.erp_px_cat_g1v2';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

	v_load_end_time := clock_timestamp();
	
	RAISE NOTICE '===========================================';
	RAISE NOTICE 'TOTAL LOAD DURATION: % seconds',
    ROUND(EXTRACT(EPOCH FROM (v_load_end_time - v_load_start_time))::numeric, 3);
	RAISE NOTICE '===========================================';
	
	RAISE NOTICE 'Bronze Layer Load Completed Successfully';
	RAISE NOTICE '===========================================';

END;
$$;

CALL bronze.load_bronze_layer();