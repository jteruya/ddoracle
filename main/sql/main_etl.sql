--Identify the Sessions we'll be looking at 
DROP TABLE IF EXISTS dashboard.Session_StartEnds;
CREATE TABLE dashboard.Session_StartEnds AS 
SELECT *, CAST(EXTRACT(Year FROM CAST(TS AS Date)) AS TEXT)||'-'||CASE WHEN CAST(EXTRACT(Month FROM CAST(TS AS Date)) AS INT) < 10 THEN '0' ELSE '' END||CAST(EXTRACT(Month FROM CAST(TS AS Date)) AS TEXT) AS YYYY_MM 
FROM (
SELECT 
Application_Id AS ApplicationId, 
User_Id AS UserId, 
CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END AS TS, 
CASE WHEN Metrics_Type_Id = 1 THEN 'Start' WHEN Metrics_Type_Id = 2 THEN 'End' END AS TS_Type
FROM PUBLIC.Fact_Sessions
WHERE Application_Id IN (SELECT ApplicationId AS ApplicationId FROM kevin.Users_Per_App WHERE CNT > 20) --Ensure we don't use any Test Apps (switch to EventCubeSummary TestEvents filter eventually)
) t;

CREATE INDEX ndx_sessionstartends_applicationid_userid_yyyymm ON dashboard.Session_StartEnds (ApplicationId, UserId, YYYY_MM);
CREATE INDEX ndx_sessionstartends_applicationid_userid_ts ON dashboard.Session_StartEnds (ApplicationId, UserId, TS);

--Identify the Durations per Each Session
DROP TABLE IF EXISTS kevin.KPI_SessionDurations;
CREATE TABLE kevin.KPI_SessionDurations AS
SELECT ApplicationId, UserId, TS_Type, TS, NEXT_TS,
CASE WHEN TS_Type = 'Start' AND NEXT_TS_Type = 'End' THEN NEXT_TS - TS  END AS Duration,
CASE WHEN TS_Type = 'Start' AND NEXT_TS_Type = 'End' THEN CAST(EXTRACT(EPOCH FROM NEXT_TS - TS) AS NUMERIC) END AS Duration_Seconds
FROM (
        SELECT ApplicationId, UserId, TS_Type, TS, MAX(TS) OVER (PARTITION BY ApplicationId, UserId ORDER BY ApplicationId, UserId, TS ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING) AS NEXT_TS, MAX(TS_Type) OVER (PARTITION BY ApplicationId, UserId ORDER BY ApplicationId, UserId, TS ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING) AS NEXT_TS_Type
        FROM kevin.Session_StartEnds 
) t
WHERE TS_Type = 'Start';

CREATE INDEX ndx_sessiondurations_applicationid ON kevin.KPI_SessionDurations (ApplicationId);