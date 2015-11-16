SELECT DISTINCT CASE WHEN SatisfactionCard_Ind = 'false' THEN 'Off' ELSE 'On' END AS SatisfactionCard_Ind, YYYY_MM, ROUND(100 * CAST(COUNT(*) OVER (PARTITION BY SatisfactionCard_Ind, YYYY_MM) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS "% of Total Events"
FROM (
SELECT app.ApplicationId, app.Name, app.StartDate, app.EndDate, sc.SatisfactionCard_Ind,
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM 
FROM AuthDB_Applications app
LEFT JOIN (SELECT ApplicationId, CAST(Metadata ->> 'send_satisfaction_card' AS BOOL) AS SatisfactionCard_Ind  FROM PUBLIC.ActivityFeedService) sc ON app.ApplicationId = sc.ApplicationId
WHERE app.StartDate >= '2015-07-01' --From when feature was turned on
AND app.StartDate <= CURRENT_DATE 
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP)
AND app.StartDate <= CURRENT_DATE
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
) t ORDER BY 1,2