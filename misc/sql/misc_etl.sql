--Get the List of Sessions and their related Metadata
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_session_os_version;
CREATE TABLE dashboard.kpi_social_metrics_session_os_version TABLESPACE FastStorage AS
SELECT *, CAST(EXTRACT(YEAR FROM Created) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM Created) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM Created) AS INT) AS YYYY_MM 
FROM (
        SELECT 
        UserId,
        AppTypeId, 
        BinaryVersion,
        StartDate AS Created
        FROM PUBLIC.V_Fact_Sessions_All
        WHERE 
        (  --Handle the old Session Format
           SRC = 'Robin'
           AND StartDate <= CURRENT_DATE --Only Session that have started in past 13 months
           AND StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP)
        ) OR
        (
           --Handle the current Session Format
           SRC IN ('Alfred','Robin_Live')
           AND MetricTypeId = 1
           AND StartDate <= CURRENT_DATE --Only Session that have started in past 13 months
           AND StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP)
        )
) t;

CREATE INDEX ndx_kpi_social_metrics_session_os_version ON dashboard.kpi_social_metrics_session_os_version(YYYY_MM,AppTypeId) TABLESPACE FastStorage;
CREATE INDEX ndx_kpi_social_metrics_session_os_version_user ON dashboard.kpi_social_metrics_session_os_version(UserId) TABLESPACE FastStorage;

--Identify the First Session per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_firstsession_os_version;
CREATE TABLE dashboard.kpi_social_metrics_firstsession_os_version TABLESPACE FastStorage AS
SELECT UserId, AppTypeId, Created, YYYY_MM 
        FROM (
                SELECT UserId, AppTypeId, Created, YYYY_MM, MIN(Created) OVER (PARTITION BY UserId) AS MinCreated
                FROM dashboard.kpi_social_metrics_session_os_version
                WHERE AppTypeId <> 0 AND UserId <> 0
        ) t WHERE Created = MinCreated;
        
--Get the list of Activity Feed views with related Metadata
CREATE TEMPORARY TABLE kpi_social_metrics_globalactivityfeed_views TABLESPACE FastStorage AS
SELECT 
ApplicationId, GlobalUserId, AppTypeId, BinaryVersion, MMM_Info, Created, CAST(EXTRACT(YEAR FROM Created) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM Created) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM Created) AS INT) AS YYYY_MM 
FROM PUBLIC.V_Fact_Views_All 
WHERE Identifier = 'activities' 
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'3 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'3 months')||'-01 00:00:00' AS TIMESTAMP) --Past 3 months
;

--CREATE INDEX ndx_kpi_social_metrics_globalactivityfeed_views ON dashboard.kpi_social_metrics_globalactivityfeed_views(ApplicationId, GlobalUserId);

--Identify the First Global Activity Feed view per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_firstglobalactivityfeed_views;
CREATE TABLE dashboard.kpi_social_metrics_firstglobalactivityfeed_views TABLESPACE FastStorage AS
SELECT ApplicationId, GlobalUserId, AppTypeId, BinaryVersion, MMM_Info, Created, YYYY_MM 
        FROM (
                SELECT ApplicationId, GlobalUserId, AppTypeId, BinaryVersion, MMM_Info, Created, YYYY_MM, MIN(Created) OVER (PARTITION BY ApplicationId, GlobalUserId) AS MinCreated
                FROM kpi_social_metrics_globalactivityfeed_views
                WHERE AppTypeId <> 0 AND GlobalUserId IS NOT NULL
        ) t WHERE Created = MinCreated;

--Identify the First Global Activity Feed view per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_device_pct;
CREATE TABLE dashboard.kpi_social_metrics_device_pct TABLESPACE FastStorage AS
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

