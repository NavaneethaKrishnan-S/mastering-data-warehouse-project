/*
===============================================================================

Procedure Name : silver.load_silver_layer
Project        : Data Warehouse
Layer          : Silver

Purpose:
Loads cleansed and transformed data from Bronze layer tables into
Silver layer tables.

Source Tables:
bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2

Target Tables:
silver.crm_cust_info
silver.crm_prd_info
silver.crm_sales_details
silver.erp_cust_az12
silver.erp_loc_a101
silver.erp_px_cat_g1v2

Process:
1. Truncate existing Silver layer tables.
2. Extract data from Bronze layer tables.
3. Apply data cleansing and standardization rules.
4. Apply business transformations and validations.
5. Load transformed data into Silver layer tables.
6. Display row counts and load duration for verification.

Data Quality Checks:
1. Remove duplicate customer records.
2. Standardize gender and marital status values.
3. Standardize country names.
4. Validate and correct sales amounts and prices.
5. Handle invalid and future dates.
6. Populate product effective start and end dates.

Warning:
1. Existing data in Silver tables will be permanently deleted before reload.
2. Bronze layer tables must be loaded successfully before executing this procedure.
3. Data transformations may modify source values to enforce data quality standards.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver_layer()
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
    RAISE NOTICE 'Starting Silver Layer Load';
    RAISE NOTICE '===========================================';

    ---------------------------------------------------------------------------
    -- CRM CUSTOMER INFO
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        RAISE NOTICE 'INSERTING DATA INTO: silver.crm_cust_info';
        
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.crm_cust_info;

        RAISE NOTICE 'crm_cust_info loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.crm_cust_info';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- CRM PRODUCT INFO
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        RAISE NOTICE 'INSERTING DATA INTO: silver.crm_prd_info';
        
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key FROM 1 FOR 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key FROM 7) AS prd_key,
            prd_nm,
            COALESCE(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - INTERVAL '1 day'
                AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.crm_prd_info;

        RAISE NOTICE 'crm_prd_info loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.crm_prd_info';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- CRM SALES DETAILS
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        RAISE NOTICE 'INSERTING DATA INTO: silver.crm_sales_details';
        
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt = 0
                    OR LENGTH(CAST(sls_order_dt AS TEXT)) <> 8
                THEN NULL
                ELSE TO_DATE(CAST(sls_order_dt AS TEXT), 'YYYYMMDD')
            END AS sls_order_dt,

            CASE
                WHEN sls_ship_dt = 0
                    OR LENGTH(CAST(sls_ship_dt AS TEXT)) <> 8
                THEN NULL
                ELSE TO_DATE(CAST(sls_ship_dt AS TEXT), 'YYYYMMDD')
            END AS sls_ship_dt,

            CASE
                WHEN sls_due_dt = 0
                    OR LENGTH(CAST(sls_due_dt AS TEXT)) <> 8
                THEN NULL
                ELSE TO_DATE(CAST(sls_due_dt AS TEXT), 'YYYYMMDD')
            END AS sls_due_dt,

            CASE
                WHEN sls_sales IS NULL
                    OR sls_sales <= 0
                    OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            CASE
                WHEN sls_price IS NULL
                    OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.crm_sales_details;

        RAISE NOTICE 'crm_sales_details loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.crm_sales_details';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP CUSTOMER
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        RAISE NOTICE 'INSERTING DATA INTO: silver.erp_cust_az12';
        
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
                ELSE cid
            END AS cid,

            CASE
                WHEN bdate > CURRENT_DATE THEN NULL
                ELSE bdate
            END AS bdate,

            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_az12;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.erp_cust_az12;

        RAISE NOTICE 'erp_cust_az12 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.erp_cust_az12';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP LOCATION
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        RAISE NOTICE 'INSERTING DATA INTO: silver.erp_loc_a101';
        
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = ''
                    OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.erp_loc_a101;

        RAISE NOTICE 'erp_loc_a101 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.erp_loc_a101';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

    ---------------------------------------------------------------------------
    -- ERP PRODUCT CATEGORY
    ---------------------------------------------------------------------------

    BEGIN
        v_start_time := clock_timestamp();

        RAISE NOTICE 'TRUNCATING TABLE: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        RAISE NOTICE 'INSERTING DATA INTO: silver.erp_px_cat_g1v2';
        
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        v_end_time := clock_timestamp();

        SELECT COUNT(*)
        INTO v_row_count
        FROM silver.erp_px_cat_g1v2;

        RAISE NOTICE 'erp_px_cat_g1v2 loaded: % rows', v_row_count;
        RAISE NOTICE 'Duration: % ms',
            ROUND((EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000)::numeric, 2);
        RAISE NOTICE '===========================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: silver.erp_px_cat_g1v2';
            RAISE NOTICE 'ERROR: %', SQLERRM;
    END;

	v_load_end_time := clock_timestamp();
	
	RAISE NOTICE '===========================================';
	RAISE NOTICE 'TOTAL LOAD DURATION: % seconds',
    ROUND(EXTRACT(EPOCH FROM (v_load_end_time - v_load_start_time))::numeric, 3);
	RAISE NOTICE '===========================================';
	
	RAISE NOTICE 'silver Layer Load Completed Successfully';
	RAISE NOTICE '===========================================';

END;
$$;

-- CALL silver.load_silver_layer();