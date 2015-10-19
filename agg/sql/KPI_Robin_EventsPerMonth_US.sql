SELECT 
'US' AS Label,
EXTRACT(YEAR FROM "Start Date") || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM "Start Date") AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM "Start Date") AS YYYYMM, COUNT(*)
FROM (

SELECT 
a.ApplicationId, a.Name, CAST(a.StartDate AS DATE) AS "Start Date", CAST(a.EndDate AS DATE) AS "End Date", COALESCE(sfdc.EventType,'_Unknown') AS "Type", CASE WHEN a.CanRegister = 'true' THEN 'Open' ELSE 'Closed' END AS "Open/Closed", b.ActiveUsers AS "Active Users", CASE WHEN te.ApplicationId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Marked as Test App?", CASE WHEN sfdc.ApplicationId IS NOT NULL THEN 'Y' ELSE 'N' END AS "In SalesForce?"
FROM AuthDB_Applications a
JOIN (SELECT ApplicationId, COUNT(*) AS ActiveUsers FROM EventCube.Agg_Session_Per_AppUser GROUP BY 1) b ON a.ApplicationId = b.ApplicationId
LEFT JOIN EventCube.TestEvents te ON a.ApplicationId = te.ApplicationId
LEFT JOIN EventCube.V_DimEventsSFDC sfdc ON a.ApplicationId = sfdc.ApplicationId 
WHERE a.StartDate < CURRENT_DATE
ORDER BY a.StartDate DESC

) t 
WHERE "Marked as Test App?" = 'N' OR ("Marked as Test App?" = 'Y' AND "In SalesForce?" = 'Y')
AND "Start Date" >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 Months') || '-01 00:00:00' AS TIMESTAMP) 
AND "Start Date" < CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'0 Months') || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') AS INT) < 10 THEN '0' ELSE '' END || EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'0 Months') || '-01 00:00:00' AS TIMESTAMP)
GROUP BY 1,2 ORDER BY 1,2

