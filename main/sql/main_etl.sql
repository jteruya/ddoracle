--Get the initial set of Sessions we'll be working with
CREATE TEMPORARY TABLE BaseSessions TABLESPACE FastStorage AS 
SELECT 
  app.*, 
  CASE
    WHEN Binary_Version IS NULL THEN NULL
    WHEN Binary_Version ~ '[A-Za-z]' THEN NULL
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 1 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version) + 1,999) AS INT) * 100)
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 2 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS INT) * 100) + (CAST(CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS INT))
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 3 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS INT) * 100) + (CAST(CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS INT))
  END AS BinaryVersionInt
--LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') NumPeriods,  
--SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS BIN1,
--SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS BIN2,
--CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS BIN3,
FROM (SELECT 
        SRC,
        ApplicationId,
        UserId, 
        DeviceId, 
        AppTypeId, 
        CASE WHEN MetricTypeId = 1 THEN StartDate WHEN MetricTypeId = 2 THEN EndDate ELSE EndDate END AS DT,
        MetricTypeId,
        StartDate,
        EndDate,
        CASE 
          WHEN BinaryVersion ~ '[A-Za-z]' AND BinaryVersion LIKE '%-%' THEN SUBSTRING(REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g'),0,POSITION('-' IN REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g')))
          WHEN BinaryVersion ~ '[A-Za-z]' AND BinaryVersion NOT LIKE '%-%' THEN SUBSTRING(REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g'),0,POSITION('[A-Za-z]' IN REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g')))
          ELSE BinaryVersion
        END AS Binary_Version
      FROM PUBLIC.V_Fact_Sessions_ALL
      WHERE (BinaryVersion IS NULL OR UPPER(BinaryVersion) NOT LIKE '%FLOCK%') --Don't include any FLOCK/Test eapps
      AND UserId IS NOT NULL
      AND ApplicationId IN (SELECT ApplicationId FROM EventCube.BaseApps) --Base Apps we'll be cubing
      ) app
;

--======================================--
-- Transformations for Downstream Usage --
--======================================--

--Get the set of Session Start/End Metrics from ALFRED source
CREATE TEMPORARY TABLE SessionStartEnds TABLESPACE FastStorage AS 
SELECT 
  CAST(EXTRACT(Year FROM CAST(TS AS Date)) AS TEXT)||'-'||CASE WHEN CAST(EXTRACT(Month FROM CAST(TS AS Date)) AS INT) < 10 THEN '0' ELSE '' END||CAST(EXTRACT(Month FROM CAST(TS AS Date)) AS TEXT) AS YYYY_MM,
  app.*, 
  CASE
    WHEN Binary_Version IS NULL THEN NULL
    WHEN Binary_Version ~ '[A-Za-z]' THEN NULL
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 1 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version) + 1,999) AS INT) * 100)
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 2 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS INT) * 100) + (CAST(CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS INT))
    WHEN LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') = 3 THEN (CAST(SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS INT) * 10000) + (CAST(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS INT) * 100) + (CAST(CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS INT))
  END AS BinaryVersionInt
--LENGTH(Binary_Version) - LENGTH(REGEXP_REPLACE(Binary_Version,'\.','','g')) / LENGTH('.') NumPeriods,  
--SUBSTRING(Binary_Version,0,POSITION('.' IN Binary_Version)) AS BIN1,
--SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),0,POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999))) AS BIN2,
--CASE WHEN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) LIKE '%.%' THEN SUBSTRING(SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999),0,POSITION('.' IN SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999))) ELSE SUBSTRING(SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999),CAST(POSITION('.' IN SUBSTRING(Binary_Version,POSITION('.' IN Binary_Version)+1,999)) AS INT) + 1,999) END AS BIN3,
FROM (SELECT 
        SRC,
        ApplicationId,
        UserId, 
        DeviceId, 
        AppTypeId, 
        --CASE WHEN MetricTypeId = 1 THEN StartDate WHEN MetricTypeId = 2 THEN EndDate ELSE EndDate END AS DT,
        CASE WHEN MetricTypeId = 1 THEN StartDate WHEN MetricTypeId = 2 THEN EndDate END AS TS, 
        CASE WHEN MetricTypeId = 1 THEN 'Start' WHEN MetricTypeId = 2 THEN 'End' END AS TS_Type,
        MetricTypeId,
        StartDate,
        EndDate,
        CASE 
          WHEN BinaryVersion ~ '[A-Za-z]' AND BinaryVersion LIKE '%-%' THEN SUBSTRING(REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g'),0,POSITION('-' IN REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g')))
          WHEN BinaryVersion ~ '[A-Za-z]' AND BinaryVersion NOT LIKE '%-%' THEN SUBSTRING(REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g'),0,POSITION('[A-Za-z]' IN REGEXP_REPLACE(BinaryVersion,'[A-Za-z]','','g')))
          ELSE BinaryVersion
        END AS Binary_Version
      FROM PUBLIC.V_Fact_Sessions_ALL
      WHERE (BinaryVersion IS NULL OR UPPER(BinaryVersion) NOT LIKE '%FLOCK%') --Don't include any FLOCK/Test eapps
      AND UserId IS NOT NULL
      AND ApplicationId IN (SELECT ApplicationId FROM EventCube.BaseApps) --Base Apps we'll be cubing
      AND SRC IN ('Alfred','Robin_Live')
      ) app
;

CREATE INDEX ndx_alfredsessionstartends_applicationid_userid_yyyymm ON SessionStartEnds (ApplicationId, UserId, YYYY_MM);
CREATE INDEX ndx_alfredsessionstartends_applicationid_userid_ts ON SessionStartEnds (ApplicationId, UserId, TS);

--Identify the Durations per Each Session
DROP TABLE IF EXISTS EventCube.Session_Durations;
CREATE TABLE EventCube.Session_Durations TABLESPACE FastStorage AS
SELECT ApplicationId, UserId, TS_Type, TS, NEXT_TS,
CASE WHEN TS_Type = 'Start' AND NEXT_TS_Type = 'End' THEN NEXT_TS - TS  END AS Duration,
CASE WHEN TS_Type = 'Start' AND NEXT_TS_Type = 'End' THEN CAST(EXTRACT(EPOCH FROM NEXT_TS - TS) AS NUMERIC) END AS Duration_Seconds
FROM (
        SELECT ApplicationId, UserId, TS_Type, TS, MAX(TS) OVER (PARTITION BY ApplicationId, UserId ORDER BY ApplicationId, UserId, TS ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING) AS NEXT_TS, MAX(TS_Type) OVER (PARTITION BY ApplicationId, UserId ORDER BY ApplicationId, UserId, TS ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING) AS NEXT_TS_Type
        FROM SessionStartEnds 
        WHERE Src IN ('Alfred','Robin_Live')
) t
WHERE TS_Type = 'Start'
UNION ALL
SELECT ApplicationId, UserId, 'Session' AS TS_Type, StartDate AS TS, EndDate AS NEXT_TS, EndDate - StartDate AS Duration, CAST(EXTRACT(EPOCH FROM EndDate - StartDate) AS NUMERIC) AS Duration_Seconds FROM BaseSessions WHERE MetricTypeId IS NULL
;

CREATE INDEX ndx_session_durations_applicationid ON EventCube.Session_Durations (ApplicationId);

--===============================================--
-- Build out the datasets for use with reporting --
--===============================================--

CREATE TABLE dashboard.Session_Durations_Weekly TABLESPACE FastStorage AS 
SELECT
CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || '-' || CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS YYYY_WW,
a.*,
CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS WeeksPast
FROM EventCube.Session_Durations a
JOIN AuthDB_Applications b ON UPPER(a.ApplicationId) = b.ApplicationId
WHERE CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) <= 8 --Within last 8 weeks
AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) >= 0
AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM b.StartDate) --Same Year
;

CREATE INDEX ndx_session_durations_weekly ON dashboard.Session_Durations_Weekly (YYYY_WW) TABLESPACE FastStorage;

CREATE TABLE dashboard.App_Durations_Weekly TABLESPACE FastStorage AS 
SELECT
CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || '-' || CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS YYYY_WW,
a.*
FROM EventCube.Session_Durations a
JOIN AuthDB_Applications b ON UPPER(a.ApplicationId) = b.ApplicationId
WHERE (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 8 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) >= 0 AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM b.StartDate)) --Within 8 weeks, same year
OR (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 0 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) <= -44 AND CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) = 1) --Within 8 weeks, different year
;

CREATE INDEX ndx_app_durations_weekly ON dashboard.App_Durations_Weekly (YYYY_WW) TABLESPACE FastStorage;
