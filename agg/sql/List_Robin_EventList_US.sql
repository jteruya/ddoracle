SELECT 
a.ApplicationId, a.Name, CAST(a.StartDate AS DATE) AS "Start Date", CAST(a.EndDate AS DATE) AS "End Date", COALESCE(sfdc.EventType,'_Unknown') AS "Type", CASE WHEN a.CanRegister = 'true' THEN 'Open' ELSE 'Closed' END AS "Open/Closed", b.ActiveUsers AS "Active Users", CASE WHEN te.ApplicationId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Marked as Test App?"
FROM AuthDB_Applications a
JOIN (SELECT ApplicationId, COUNT(*) AS ActiveUsers FROM EventCube.Agg_Session_Per_AppUser GROUP BY 1) b ON a.ApplicationId = b.ApplicationId
LEFT JOIN EventCube.TestEvents te ON a.ApplicationId = te.ApplicationId
LEFT JOIN EventCube.V_DimEventsSFDC sfdc ON a.ApplicationId = sfdc.ApplicationId 
WHERE a.StartDate < CURRENT_DATE
ORDER BY a.StartDate DESC

