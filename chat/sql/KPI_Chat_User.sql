SELECT 
  regexp_replace(a."Event", ',', '', 'g'),
  CAST(b.StartDate AS DATE) AS "Start",
  CAST(b.EndDate AS DATE) AS "End",  
  a."Attendees Listed",
  COALESCE(a."Adoption %",0.00) AS "% Active Attendees",
  COALESCE(a."% of Active Attendees - Tapped Direct Messages in Menu",0.00) AS "% Active Attendees - Tapped Direct Messages in Menu",
  COALESCE(a."% of Active Attendees - Sent Message",0.00) AS "% Active Attendees - Sent Message",
  COALESCE(a."% of Active Attendees - Received Message",0.00) AS "% Active Attendees - Received Message",
  COALESCE(a."% of Active Attendees - Were Blocked",0.00) AS "% Active Attendees - Were Blocked",
  COALESCE(a."% of Attendees - Inactive + Received Message (from CMS total)",0.00) AS "% of Attendees (Inactive + Received Message)"
FROM dashboard.Chat_Agg_User a
JOIN PUBLIC.AuthDB_Applications b ON a."ApplicationId" = b.ApplicationId 
WHERE a."ApplicationId" NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND b.StartDate <= CURRENT_DATE
ORDER BY b.StartDate DESC