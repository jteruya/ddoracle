--=========================================================
--== NOTIFICATIONS ==--
CREATE TEMPORARY TABLE Fact_Notifications_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Notifications_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--Notifications per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Notifications_per_Day;
CREATE TABLE dashboard.Agg_Fact_Notifications_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Notifications_DT GROUP BY 1 ORDER BY 1; 

--Notifications per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Notifications_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Notifications_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Notifications_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Notifications_DT;

--=========================================================
--== ACTIONS ==--

--Load the Actions Set into Memory
CREATE TEMPORARY TABLE Fact_Actions_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Actions_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--Actions per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Actions_per_Day;
CREATE TABLE dashboard.Agg_Fact_Actions_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Actions_DT GROUP BY 1 ORDER BY 1; 

--Actions per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Actions_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Actions_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Actions_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Actions_DT;

--=========================================================
--== VIEWS ==--
CREATE TEMPORARY TABLE Fact_Views_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Views_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--Views per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Views_per_Day;
CREATE TABLE dashboard.Agg_Fact_Views_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Views_DT GROUP BY 1 ORDER BY 1; 

--Views per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Views_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Views_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Views_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Views_DT;

--=========================================================
--== IMPRESSIONS ==--
CREATE TEMPORARY TABLE Fact_Impressions_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Impressions_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--Impressions per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Impressions_per_Day;
CREATE TABLE dashboard.Agg_Fact_Impressions_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Impressions_DT GROUP BY 1 ORDER BY 1; 

--Impressions per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Impressions_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Impressions_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Impressions_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Impressions_DT;

--=========================================================
--== SESSION START/ENDS ==--
CREATE TEMPORARY TABLE Fact_Sessions_DT TABLESPACE FastStorage AS
SELECT CAST(StartDate AS DATE) AS DT 
FROM PUBLIC.Fact_Sessions_LIVE
WHERE StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND StartDate < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP)
AND MetricTypeId = 1
UNION ALL
SELECT CAST(EndDate AS DATE) AS DT 
FROM PUBLIC.V_Fact_Sessions_ALL
WHERE EndDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND EndDate < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP)
AND MetricTypeId = 2;

--Session Start/Ends per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Sessions_per_Day;
CREATE TABLE dashboard.Agg_Fact_Sessions_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Sessions_DT GROUP BY 1 ORDER BY 1; 

--Session Start/Ends per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Sessions_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Sessions_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Sessions_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Sessions_DT;

--=========================================================
--== STATES ==--
CREATE TEMPORARY TABLE Fact_States_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_States_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--States per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_States_per_Day;
CREATE TABLE dashboard.Agg_Fact_States_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_States_DT GROUP BY 1 ORDER BY 1; 

--States per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_States_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_States_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_States_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_States_DT;

--=========================================================
--== ERRORS ==--
CREATE TEMPORARY TABLE Fact_Errors_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Errors_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--States per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Errors_per_Day;
CREATE TABLE dashboard.Agg_Fact_Errors_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Errors_DT GROUP BY 1 ORDER BY 1; 

--States per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Errors_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Errors_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Errors_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Errors_DT;

--=========================================================
--== CHECKPOINTS ==--
CREATE TEMPORARY TABLE Fact_Checkpoints_DT TABLESPACE FastStorage AS
SELECT CAST(Created AS DATE) AS DT 
FROM PUBLIC.Fact_Checkpoints_LIVE
WHERE Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'4 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'4 Months') || '-01 00:00:00' AS TIMESTAMP) AND Created < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP);

--States per Day
DROP TABLE IF EXISTS dashboard.Agg_Fact_Checkpoints_per_Day;
CREATE TABLE dashboard.Agg_Fact_Checkppoints_per_Day AS
SELECT DT, COUNT(*) AS CNT FROM Fact_Errors_DT GROUP BY 1 ORDER BY 1; 

--States per Month
DROP TABLE IF EXISTS dashboard.Agg_Fact_Checkpoints_per_YYYYMM;
CREATE TABLE dashboard.Agg_Fact_Checkpoints_per_YYYYMM AS
SELECT EXTRACT(YEAR FROM DT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM DT) AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM DT) AS YYYY_MM, SUM(CNT) AS CNT FROM dashboard.Agg_Fact_Checkpoints_per_Day GROUP BY 1 ORDER BY 1;

--Cleanup the memory
DROP TABLE IF EXISTS Fact_Checkpoints_DT;

--=========================================================

--Overall Set of Counts per Metric Type
/*
SELECT 'Views' AS Label, * FROM dashboard.Agg_Fact_Views_per_YYYYMM 
UNION ALL
SELECT 'Actions' AS Label, * FROM dashboard.Agg_Fact_Actions_per_YYYYMM
UNION ALL
SELECT 'Impressions' AS Label, * FROM dashboard.Agg_Fact_Impressions_per_YYYYMM
UNION ALL
SELECT 'Session Start/Ends' AS Label, * FROM dashboard.Agg_Fact_Sessions_per_YYYYMM
UNION ALL
SELECT 'States' AS Label, * FROM dashboard.Agg_Fact_States_per_YYYYMM
UNION ALL
SELECT 'Notifications' AS Label, * FROM dashboard.Agg_Fact_Notifications_per_YYYYMM;
*/
