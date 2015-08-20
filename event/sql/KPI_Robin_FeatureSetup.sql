--Per Event, is a Poll set up?
SELECT 
CAST('Poll Setup' AS TEXT) AS Typ,
YYYY_MM, 
--COUNT(*) AS Events, 
--SUM(Poll_Setup_Ind) AS Events_w_Polls,
ROUND(100 * CAST(SUM(Poll_Setup_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS PCT_Events_w_Polls
FROM (
SELECT
app.ApplicationId,
CASE WHEN poll.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS Poll_Setup_Ind,
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM AuthDB_Applications app
LEFT JOIN (SELECT DISTINCT ApplicationId FROM PUBLIC.Ratings_Surveys WHERE IsPoll = 'true' AND IsDisabled = 'false') poll ON app.ApplicationId = poll.ApplicationId
WHERE app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CURRENT_DATE - INTERVAL'7 months'
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
) t GROUP BY 1,2 ORDER BY 1,2