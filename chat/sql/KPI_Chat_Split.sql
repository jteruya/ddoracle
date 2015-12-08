--Split the Users by interaction with Mesaging and identify their Session Counts per group
SELECT 
  --t.ApplicationId AS "ApplicationId", 
  app.Name AS "Event",
  CAST(b.StartDate AS DATE) AS "Start",
  CAST(b.EndDate AS DATE) AS "End",    
  MessagingInd AS "Relation to Messaging?", 
  COUNT(*)  AS "Active Attendees", 
  ROUND(MEDIAN(Sessions),2) AS "Sessions (Median)"
FROM (
        SELECT 
          du.ApplicationId, du.UserId, 
          CASE WHEN msg.UserId IS NOT NULL THEN 'Y' ELSE 'N' END AS MessagingInd, 
          agg.Sessions
        FROM dashboard.Chat_Dim_Users du
        LEFT JOIN (
                --Users that engaged with Messaging in any way: Tapped the Menu Item or viewed a Chat (two entry points)
                SELECT DISTINCT ApplicationId, UserId FROM dashboard.Chat_Fact_MenuTapMessages WHERE ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events) 
                UNION 
                SELECT DISTINCT ApplicationId, UserId FROM dashboard.Chat_Fact_Views WHERE ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events)        
        ) msg ON du.UserId = msg.UserId
        JOIN EventCube.Agg_Session_Per_AppUser agg ON du.UserId = agg.UserId --Only Active Users
        WHERE du.DD_Ind = 0

) t 
JOIN dashboard.Chat_Dim_Events app ON t.ApplicationId = app.ApplicationId
JOIN PUBLIC.AuthDB_Applications b ON t.ApplicationId = b.ApplicationId 
WHERE t.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND b.StartDate <= CURRENT_DATE
GROUP BY 1,2,3,4
ORDER BY 2 DESC, 1 ASC;