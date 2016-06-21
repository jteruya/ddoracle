--Identify the Durations per Each Session
DROP TABLE IF EXISTS EventCube.Session_Durations;
CREATE TABLE EventCube.Session_Durations TABLESPACE FastStorage AS
SELECT 
  ApplicationId, 
  UserId, 
  GlobalUserId, 
  StartDate, 
  EndDate, 
  EndDate - StartDate AS Duration, 
  CAST(EXTRACT(EPOCH FROM EndDate - StartDate) AS NUMERIC) AS Duration_Seconds
FROM EventCube.Sessions
WHERE (BinaryVersion IS NULL OR UPPER(BinaryVersion) NOT LIKE '%FLOCK%') --Don't include any FLOCK/Test eapps
AND (UserId IS NOT NULL OR GlobalUserId IS NOT NULL)
AND ApplicationId IN (SELECT ApplicationId FROM EventCube.BaseApps) --Base Apps we'll be cubing
AND StartDate IS NOT NULL AND EndDate IS NOT NULL;

--CREATE INDEX ndx_session_durations_applicationid ON EventCube.Session_Durations (ApplicationId);

--===============================================--
-- Build out the datasets for use with reporting --
--===============================================--
DROP TABLE IF EXISTS dashboard.Session_Durations_Weekly;
CREATE TABLE dashboard.Session_Durations_Weekly TABLESPACE FastStorage AS 
SELECT
CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || CASE WHEN CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 10 THEN '-0' ELSE '-' END || CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS YYYY_WW,
a.*,
CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS WeeksPast
FROM EventCube.Session_Durations a
JOIN AuthDB_Applications b ON UPPER(a.ApplicationId) = b.ApplicationId
WHERE (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 16 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) >= 1 AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM b.StartDate)) --Within 16 weeks, same year
OR (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 0 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) <= -36 AND CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) = 1) --Within 16 weeks, different year
;

CREATE INDEX ndx_session_durations_weekly ON dashboard.Session_Durations_Weekly (YYYY_WW) TABLESPACE FastStorage;

DROP TABLE IF EXISTS dashboard.App_Durations_Weekly;
CREATE TABLE dashboard.App_Durations_Weekly TABLESPACE FastStorage AS 
SELECT
CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || CASE WHEN CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 10 THEN '-0' ELSE '-' END || CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS YYYY_WW,
a.*
FROM EventCube.Session_Durations a
JOIN AuthDB_Applications b ON UPPER(a.ApplicationId) = b.ApplicationId
WHERE (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 16 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) >= 1 AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM b.StartDate)) --Within 16 weeks, same year
OR (CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) < 0 AND CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) <= -36 AND CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) = 1) --Within 16 weeks, different year
;

CREATE INDEX ndx_app_durations_weekly ON dashboard.App_Durations_Weekly (YYYY_WW) TABLESPACE FastStorage;
