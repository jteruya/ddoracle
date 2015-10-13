SELECT KPI, YYYY_MM, ROUND(PCT_Users,2) AS PCT_Users FROM (

--What % of Active Users in the App have posted a Status Update?
SELECT 
  CAST('% of Active Users with 1+ Status Updates' AS TEXT) AS KPI,
  CAST(EXTRACT(YEAR FROM t.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) AS YYYY_MM, 
  --COUNT(*) AS Users, 
  --SUM(StatusUpdateInd) AS UsersWithStatusUpdates, 
  100 * CAST(SUM(StatusUpdateInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Users
FROM (
SELECT iu.ApplicationId, app.StartDate, iu.UserId, CASE WHEN uci.UserId IS NOT NULL THEN 1 ELSE 0 END AS StatusUpdateInd
FROM EventCube.Agg_Session_Per_AppUser agg --Only users that at least had a session in the app
JOIN AuthDB_IS_Users iu ON agg.UserId = iu.UserId
JOIN AuthDB_Applications app ON iu.ApplicationId = app.ApplicationId
LEFT JOIN (SELECT DISTINCT ApplicationId, UserId FROM Ratings_UserCheckIns) uci ON iu.ApplicationId = uci.ApplicationId AND iu.UserId = uci.UserId
WHERE iu.IsDisabled = 0
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
) t 
GROUP BY 1,2

UNION ALL

--What % of Active Users in the App have looked at another User's Profile?
SELECT 
  CAST('% of Active Users with 1+ Profile Views (not self)' AS TEXT) AS KPI,
  CAST(EXTRACT(YEAR FROM t.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) AS YYYY_MM, 
  --COUNT(*) AS Users, 
  --SUM(StatusUpdateInd) AS UsersWithStatusUpdates, 
  100 * CAST(SUM(StatusUpdateInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Users
FROM (
SELECT iu.ApplicationId, app.StartDate, iu.UserId, CASE WHEN uci.UserId IS NOT NULL THEN 1 ELSE 0 END AS StatusUpdateInd
FROM EventCube.Agg_Session_Per_AppUser agg --Only users that at least had a session in the app
JOIN AuthDB_IS_Users iu ON agg.UserId = iu.UserId
JOIN AuthDB_Applications app ON iu.ApplicationId = app.ApplicationId
LEFT JOIN (SELECT DISTINCT ApplicationId, UserId FROM dashboard.kpi_social_metrics_profileviews_classify WHERE ElseProfileView_Ind = 1) uci ON iu.ApplicationId = uci.ApplicationId AND iu.UserId = uci.UserId
WHERE iu.IsDisabled = 0
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
) t 
GROUP BY 1,2

UNION ALL

--What % of Active Users in the App have looked at their own Profile?
SELECT 
  CAST('% of Active Users with 1+ Self-Profile Views' AS TEXT) AS KPI,
  CAST(EXTRACT(YEAR FROM t.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM t.StartDate) AS INT) AS YYYY_MM, 
  --COUNT(*) AS Users, 
  --SUM(StatusUpdateInd) AS UsersWithStatusUpdates, 
  100 * CAST(SUM(StatusUpdateInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Users
FROM (
SELECT iu.ApplicationId, app.StartDate, iu.UserId, CASE WHEN uci.UserId IS NOT NULL THEN 1 ELSE 0 END AS StatusUpdateInd
FROM EventCube.Agg_Session_Per_AppUser agg --Only users that at least had a session in the app
JOIN AuthDB_IS_Users iu ON agg.UserId = iu.UserId
JOIN AuthDB_Applications app ON iu.ApplicationId = app.ApplicationId
LEFT JOIN (SELECT DISTINCT ApplicationId, UserId FROM dashboard.kpi_social_metrics_profileviews_classify WHERE ElseProfileView_Ind = 0) uci ON iu.ApplicationId = uci.ApplicationId AND iu.UserId = uci.UserId
WHERE iu.IsDisabled = 0
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
) t 
GROUP BY 1,2

UNION ALL

--What % of Active Users in the App have looked at an Exhibitor Profile (Events with Exhibitors)?
SELECT 
  CAST('% of Active Users with 1+ Exhibitor Detail View (Events with Exhibitors)' AS TEXT) AS KPI,
  YYYY_MM, 
  100 * CAST(SUM(ViewExhibitor_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Users
FROM dashboard.kpi_social_metrics_exhibitorviews
GROUP BY 1,2

) t ORDER BY 1,2;