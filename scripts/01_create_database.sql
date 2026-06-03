/*
===============================================================================
 Purpose
 -------
 Creates the DataWarehouse database if it does not already exist.

 Warning
 -------
 - Execute while connected to the PostgreSQL 'postgres' database.
 - Requires CREATE DATABASE privilege.
 - PostgreSQL does not support CREATE DATABASE IF NOT EXISTS.

===============================================================================
*/

CREATE DATABASE "DataWarehouse";