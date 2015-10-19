SELECT 
'EU' AS Label,
CAST(CAST(YEAR("Start Date") AS VARCHAR) + '-' + CASE WHEN CAST(MONTH("Start Date") AS INT) < 10 THEN '0' ELSE '' END + CAST(MONTH("Start Date") AS VARCHAR) AS VARCHAR) AS YYYYMM,
COUNT(*) AS COUNT
FROM (

SELECT 
a.ApplicationId, a.Name, CAST(a.StartDate AS DATE) AS "Start Date", CAST(a.EndDate AS DATE) AS "End Date", COALESCE(a.EventType,'_Unknown') AS "Type", CASE WHEN a.CanRegister = 'true' THEN 'Open' ELSE 'Closed' END AS "Open/Closed", NULL AS "Active Users", NULL AS "Marked as Test App?", NULL AS "In SalesForce?"
FROM AuthDB.dbo.Applications a
--JOIN (SELECT ApplicationId, COUNT(*) AS ActiveUsers FROM EventCube.Agg_Session_Per_AppUser GROUP BY 1) b ON a.ApplicationId = b.ApplicationId
--LEFT JOIN EventCube.TestEvents te ON a.ApplicationId = te.ApplicationId
--LEFT JOIN EventCube.V_DimEventsSFDC sfdc ON a.ApplicationId = sfdc.ApplicationId 
WHERE a.StartDate < GETDATE()
--ORDER BY a.StartDate DESC

) t 
WHERE "Start Date" >= CAST(CAST(YEAR(DATEADD(mm,-13,GETDATE())) AS VARCHAR) + '-' + CASE WHEN CAST(MONTH(DATEADD(mm,-13,GETDATE())) AS INT) < 10 THEN '0' ELSE '' END + CAST(MONTH(DATEADD(mm,-13,GETDATE())) AS VARCHAR) + '-01 00:00:00' AS DATETIME)
AND "Start Date" < CAST(CAST(YEAR(DATEADD(mm,0,GETDATE())) AS VARCHAR) + '-' + CASE WHEN CAST(MONTH(DATEADD(mm,0,GETDATE())) AS INT) < 10 THEN '0' ELSE '' END + CAST(MONTH(DATEADD(mm,0,GETDATE())) AS VARCHAR) + '-01 00:00:00' AS DATETIME)
GROUP BY CAST(CAST(YEAR("Start Date") AS VARCHAR) + '-' + CASE WHEN CAST(MONTH("Start Date") AS INT) < 10 THEN '0' ELSE '' END + CAST(MONTH("Start Date") AS VARCHAR) AS VARCHAR)


