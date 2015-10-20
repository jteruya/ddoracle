SELECT 
  a.ApplicationId AS "ApplicationId", 
  REPLACE(a.Name,',','') AS "Event", 
  CAST(a.StartDate AS DATE) AS "Start Date", 
  CAST(a.EndDate AS DATE) AS "End Date", 
  CASE
    WHEN sfdc.EventType = 'Expo (<2:1 session:exhibitor ratio)' THEN 'Expo'
    WHEN sfdc.EventType = 'Conference (>2:1 session:exhibitor ratio)' THEN 'Conference'
    WHEN sfdc.EventType = 'Corporate External' THEN 'Corp. External'
    WHEN sfdc.EventType = 'Corporate Internal' THEN 'Corp. Internal'
    WHEN sfdc.EventType IS NOT NULL THEN sfdc.EventType
    WHEN sfdc.EventType IS NULL THEN '_Unknown'
  END AS "Type", 
  CASE 
    WHEN a.CanRegister = 'true' THEN 'Open' 
    ELSE 'Closed' 
  END AS "Open / Closed", 
  b.ActiveUsers AS "Active Users", 
  CASE 
    WHEN te.ApplicationId IS NOT NULL THEN 'Y' 
    ELSE 'N' 
  END AS "Marked as Test App"
FROM AuthDB_Applications a
JOIN (SELECT ApplicationId, COUNT(*) AS ActiveUsers FROM EventCube.Agg_Session_Per_AppUser GROUP BY 1) b ON a.ApplicationId = b.ApplicationId
LEFT JOIN EventCube.TestEvents te ON a.ApplicationId = te.ApplicationId
LEFT JOIN EventCube.V_DimEventsSFDC sfdc ON a.ApplicationId = sfdc.ApplicationId 
WHERE a.StartDate < CURRENT_DATE
AND a.StartDate >= CURRENT_DATE - INTERVAL'4 months'
ORDER BY a.StartDate DESC

