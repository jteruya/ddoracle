SELECT 
  a.ApplicationId AS "ApplicationId", 
  REPLACE(a.Name,',','') AS "Event", 
  CAST(a.StartDate AS DATE) AS "Start Date", 
  CAST(a.EndDate AS DATE) AS "End Date", 
  CASE
    WHEN a.EventType = 'Expo (<2:1 session:exhibitor ratio)' THEN 'Expo'
    WHEN a.EventType = 'Conference (>2:1 session:exhibitor ratio)' THEN 'Conference'
    WHEN a.EventType = 'Corporate External' THEN 'Corp. External'
    WHEN a.EventType = 'Corporate Internal' THEN 'Corp. Internal'
    WHEN a.EventType IS NOT NULL THEN a.EventType
    WHEN a.EventType IS NULL THEN '_Unknown'
  END AS "Type", 
  CASE 
    WHEN a.OpenEvent = 1 THEN 'Open' 
    ELSE 'Closed' 
  END AS "Open / Closed", 
  a.Users AS "Active Users", 
  CASE 
    WHEN te.ApplicationId IS NOT NULL THEN 'Y' 
    ELSE 'N' 
  END AS "Marked as Test App"
FROM EventCube.EventCubeSummary a
LEFT JOIN EventCube.TestEvents te ON a.ApplicationId = te.ApplicationId
WHERE a.StartDate < CURRENT_DATE
AND a.StartDate >= CURRENT_DATE - INTERVAL'4 months'
ORDER BY a.StartDate DESC
;

