SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;

------------------------------
------------------------------

SELECT
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

------------------------------
------------------------------

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;

SELECT COUNT(*)
FROM silver.crm_cust_info
WHERE cst_marital_status IS NULL;


SELECT COUNT(*) FROM silver.crm_cust_info;
