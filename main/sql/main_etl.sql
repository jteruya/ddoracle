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