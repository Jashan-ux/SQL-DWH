/* 
Stored Procedure : Load Bronze Layer (Source--> Bronze Schema)
====================================================
This is a Stored procedure , that loads the data into 'bronze' schema from the external  CSV files .
Actions :
  -It basically full load the data (Truncate + Insert)
  -It truncate the tables , and load the full data into the tables to maintain consistency.
  -It uses 'BULK Insert' that is a ddl command to insert data in bulk.
----------------------------------------------------------------------
No parameters needed,  and does'nt return any values.
--------------------------------------------------------
USAGE Example :
  EXEC load_bronze ;
===========================================================
*/





CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @bronze_load_time_start DATETIME , @bronze_end_time DATETIME
	DECLARE @start_time DATETIME, @end_time DATETIME
	BEGIN TRY

	SET @bronze_load_time_start = GETDATE()
	PRINT '================================================';
	PRINT 'Loading Bronze Layer';
	PRINT '================================================';

	PRINT '------------------------------------------------';
	PRINT 'Loading CRM Tables' ;
	PRINT '------------------------------------------------';

	
	SET @start_time = GETDATE()
	PRINT'>> TRUNCATING TABLE bronze.crm_cust_info...' 
	TRUNCATE TABLE bronze.crm_cust_info 
	PRINT'>> Inserting Data Into : bronze.crm_cust_info' 

	BULK INSERT bronze.crm_cust_info
	FROM 'D:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	)
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '------------------------------------------------';


	SET @start_time = GETDATE()
	PRINT'>> TRUNCATING TABLE bronze.crm_prd_info...' ;
	TRUNCATE TABLE bronze.crm_prd_info;

	PRINT'>> Inserting into Table bronze.crm_prd_info...';	

	BULK INSERT bronze.crm_prd_info
	FROM 'D:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW  = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE()

	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '------------------------------------------------';

	SET @start_time =  GETDATE()

	PRINT'>> TRUNCATING TABLE bronze.crm_sales_details...' ;

	TRUNCATE TABLE bronze.crm_sales_details;
	PRINT'>> Inserting into Table bronze.crm_sales_details...';	
	
	 
	BULK INSERT bronze.crm_sales_details
	FROM 'D:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		TABLOCK
	)
	SET @end_time = GETDATE()

	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '------------------------------------------------';
	

	PRINT '------------------------------------------------';
	PRINT 'Loading ERP Tables' ;
	PRINT '------------------------------------------------';



	SET @start_time = GETDATE()

	PRINT'>> TRUNCATING TABLE bronze.erp_loc_a101...' ;
	TRUNCATE TABLE bronze.erp_loc_a101 ;
	PRINT'>> Inserting into Table bronze.erp_loc_a101...';	

	BULK INSERT bronze.erp_loc_a101
	FROM 'D:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '------------------------------------------------';

	SET @start_time = GETDATE()
	PRINT'>> TRUNCATING TABLE bronze.erp_cust_az12...' ;
	TRUNCATE TABLE bronze.erp_cust_az12 ;
	PRINT'>> Inserting into Table bronze.erp_cust_az12...';
	BULK INSERT bronze.erp_cust_az12 
	FROM 'D:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE()

	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '------------------------------------------------';

	SET @start_time = GETDATE()
	PRINT'>> TRUNCATING TABLE bronze.erp_px_cat_g1v2...' ;
	TRUNCATE TABLE bronze.erp_px_cat_g1v2 ;
	PRINT'>> Inserting into Table bronze.erp_px_cat_g1v2...';
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'D:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) + 'seconds' ;

	PRINT '-----------------------------------------------'
	SET @bronze_end_time = GETDATE()
	PRINT'>> BRONZE Layer loading duration : '+ CAST(DATEDIFF(second, @bronze_load_time_start, @bronze_end_time) AS NVARCHAR);

	END TRY
	BEGIN CATCH
		PRINT '==========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================='
	END CATCH
	
END


