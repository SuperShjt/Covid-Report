CREATE database covid_db;

use covid_db;


SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=500;
set hive.exec.max.dynamic.partitions.pernode=500;


CREATE TABLE IF NOT EXISTS covid_db.covid_staging 
(
 Country 			                STRING,
 Total_Cases   		                DOUBLE,
 New_Cases    		                DOUBLE,
 Total_Deaths                       DOUBLE,
 New_Deaths                         DOUBLE,
 Total_Recovered                    DOUBLE,
 Active_Cases                       DOUBLE,
 Serious		                  	DOUBLE,
 Tot_Cases                   		DOUBLE,
 Deaths                      		DOUBLE,
 Total_Tests                   		DOUBLE,
 Tests			                 	DOUBLE,
 CASES_per_Test                     DOUBLE,
 Death_in_Closed_Cases     	        STRING,
 Rank_by_Testing_rate 		        DOUBLE,
 Rank_by_Death_rate    		        DOUBLE,
 Rank_by_Cases_rate    		        DOUBLE,
 Rank_by_Death_of_Closed_Cases   	DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED by ','
STORED as TEXTFILE
LOCATION '/user/cloudera/ds/COVID_HDFS_LZ'
tblproperties ("skip.header.line.count"="1", "serialization.null.format" = "''");

CREATE EXTERNAL TABLE IF NOT EXISTS covid_db.covid_ds_partitioned 
(
 Country 			                STRING,
 Total_Cases   		                DOUBLE,
 New_Cases    		                DOUBLE,
 Total_Deaths                       DOUBLE,
 New_Deaths                         DOUBLE,
 Total_Recovered                    DOUBLE,
 Active_Cases                       DOUBLE,
 Serious		                  	DOUBLE,
 Tot_Cases                   		DOUBLE,
 Deaths                      		DOUBLE,
 Total_Tests                   		DOUBLE,
 Tests			                 	DOUBLE,
 CASES_per_Test                     DOUBLE,
 Death_in_Closed_Cases     	        STRING,
 Rank_by_Testing_rate 		        DOUBLE,
 Rank_by_Death_rate    		        DOUBLE,
 Rank_by_Cases_rate    		        DOUBLE,
 Rank_by_Death_of_Closed_Cases   	DOUBLE
)
PARTITIONED BY (COUNTRY_NAME STRING)
STORED as TEXTFILE
LOCATION '/user/cloudera/ds/COVID_HDFS_PARTITIONED'
tblproperties ("serialization.null.format" = "''");

FROM
covid_db.covid_staging
INSERT INTO TABLE covid_db.covid_ds_partitioned PARTITION(COUNTRY_NAME)
SELECT *,Country;


CREATE EXTERNAL TABLE covid_db.covid_final_output 
(
 TOP_DEATH 			                STRING,
 TOP_TEST 			                STRING
)
PARTITIONED BY (COUNTRY_NAME STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED by ','
STORED as TEXTFILE
LOCATION '/user/cloudera/ds/COVID_FINAL_OUTPUT';


INSERT INTO TABLE covid_db.covid_final_output PARTITION(COUNTRY_NAME)
SELECT DISTINCT "" as TOP_DEATH, Total_Tests as TOP_TEST, Country
FROM covid_db.covid_ds_partitioned
   WHERE covid_ds_partitioned.Total_Tests is not null and country <> "World" 
   ORDER BY covid_ds_partitioned.Total_Tests DESC
   LIMIT 10;

INSERT INTO TABLE covid_db.covid_final_output PARTITION(COUNTRY_NAME)
SELECT DISTINCT total_deaths, "", Country
   FROM covid_ds_partitioned
   WHERE covid_ds_partitioned.total_deaths is not null and country <> "World"
   ORDER BY covid_ds_partitioned.total_deaths DESC
   LIMIT 10;

