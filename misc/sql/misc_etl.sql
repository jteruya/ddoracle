--Get the List of Sessions and their related Metadata
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_session_os_version;
CREATE TABLE dashboard.kpi_social_metrics_session_os_version AS
SELECT *, CAST(EXTRACT(YEAR FROM Created) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM Created) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM Created) AS INT) AS YYYY_MM 
FROM (
        SELECT 
        User_Id AS UserId,
        App_Type_Id AS AppTypeId, 
        Binary_Version AS BinaryVersion,
        CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END AS Created
        FROM PUBLIC.Fact_Sessions_Old
        WHERE CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END <= CURRENT_DATE --Only Session that have started in past 13 months
        AND CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END >= CURRENT_DATE - INTERVAL'13 months') t;

CREATE INDEX ndx_kpi_social_metrics_session_os_version ON dashboard.kpi_social_metrics_session_os_version(YYYY_MM,AppTypeId);
CREATE INDEX ndx_kpi_social_metrics_session_os_version_user ON dashboard.kpi_social_metrics_session_os_version(UserId);

--Identify the First Session per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_firstsession_os_version;
CREATE TABLE dashboard.kpi_social_metrics_firstsession_os_version AS
SELECT UserId, AppTypeId, Created, YYYY_MM 
        FROM (
                SELECT UserId, AppTypeId, Created, YYYY_MM, MIN(Created) OVER (PARTITION BY UserId) AS MinCreated
                FROM dashboard.kpi_social_metrics_session_os_version
                WHERE AppTypeId <> 0 AND UserId <> 0
        ) t WHERE Created = MinCreated;
        
--Get the list of Activity Feed views with related Metadata
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_globalactivityfeed_views;
CREATE TABLE dashboard.kpi_social_metrics_globalactivityfeed_views AS
SELECT 
Application_Id AS ApplicationId, Global_User_Id AS GlobalUserId, App_Type_Id AS AppTypeId, Binary_Version AS BinaryVersion, MMM_Info, Created, CAST(EXTRACT(YEAR FROM Created) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM Created) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM Created) AS INT) AS YYYY_MM 
FROM PUBLIC.Fact_Views_Old WHERE Identifier = 'activities' AND Created >= CURRENT_DATE - INTERVAL'5 months';

--CREATE INDEX ndx_kpi_social_metrics_globalactivityfeed_views ON dashboard.kpi_social_metrics_globalactivityfeed_views(ApplicationId, GlobalUserId);

--Identify the First Global Activity Feed view per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_firstglobalactivityfeed_views;
CREATE TABLE dashboard.kpi_social_metrics_firstglobalactivityfeed_views AS
SELECT ApplicationId, GlobalUserId, AppTypeId, BinaryVersion, MMM_Info, Created, YYYY_MM 
        FROM (
                SELECT ApplicationId, GlobalUserId, AppTypeId, BinaryVersion, MMM_Info, Created, YYYY_MM, MIN(Created) OVER (PARTITION BY ApplicationId, GlobalUserId) AS MinCreated
                FROM dashboard.kpi_social_metrics_globalactivityfeed_views
                WHERE AppTypeId <> 0 AND GlobalUserId IS NOT NULL
        ) t WHERE Created = MinCreated;

--Identify the First Global Activity Feed view per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_device_pct;
CREATE TABLE dashboard.kpi_social_metrics_device_pct AS
SELECT * FROM (

        --Get the distribution of Devices across all Users (iOS)
        SELECT CAST('iOS' AS TEXT) AS OS, * FROM (
                SELECT MMM_Info, YYYY_MM, 
                --CNT, SUM(CNT) OVER (PARTITION BY YYYY_MM) AS Total 
                ROUND(100 * CAST(CNT AS NUMERIC) / CAST(SUM(CNT) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_CNT
                FROM (
                        SELECT YYYY_MM, MMM_Info, COUNT(DISTINCT ApplicationId||GlobalUserId) AS CNT 
                        FROM dashboard.kpi_social_metrics_firstglobalactivityfeed_views
                        WHERE AppTypeId IN (1,2)
                        GROUP BY 1,2
                ) t
        ) t WHERE PCT_CNT >= 1.0
        UNION ALL
        --Get the distribution of Devices across all Users (Android)
        SELECT CAST('Android' AS TEXT) AS OS, * FROM (
                SELECT MMM_Info, YYYY_MM, 
                --CNT, SUM(CNT) OVER (PARTITION BY YYYY_MM) AS Total 
                ROUND(100 * CAST(CNT AS NUMERIC) / CAST(SUM(CNT) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_CNT
                FROM (
                        SELECT YYYY_MM, MMM_Info, COUNT(DISTINCT ApplicationId||GlobalUserId) AS CNT 
                        FROM dashboard.kpi_social_metrics_firstglobalactivityfeed_views
                        WHERE AppTypeId IN (3)
                        GROUP BY 1,2
                ) t
        ) t WHERE PCT_CNT >= 1.0
) t
ORDER BY 1,2;

