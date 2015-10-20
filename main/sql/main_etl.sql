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
