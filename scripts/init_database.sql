-- Create Database 'DataWarehouse'
/* 
WARNING :
Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution and ensure you haveproper backup plan
*/

USE master ;
GO

-- Drop and recreate the 'DataWarehouse' database

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse') 
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse ;
END ;
GO

-- Create the 'DataWarehouse' database

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schema

CREATE SCHEMA bronze ;
GO

CREATE SCHEMA silver ;
GO

CREATE SCHEMA gold ;


-- This was the first step of plan execution
