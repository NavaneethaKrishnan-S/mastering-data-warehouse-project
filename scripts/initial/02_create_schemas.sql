/*
===============================================================================

 Purpose
 -------
 Creates the logical schemas used by the Data Warehouse.

     bronze : Raw source data
     silver : Cleansed and transformed data
     gold   : Business-ready reporting data

 Warning
 -------
 - Execute while connected to the DataWarehouse database.
 - Safe to execute multiple times.

===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

COMMENT ON SCHEMA bronze IS
'Raw ingestion layer containing source system data';

COMMENT ON SCHEMA silver IS
'Cleansed and transformed data layer';

COMMENT ON SCHEMA gold IS
'Business-ready presentation and reporting layer';