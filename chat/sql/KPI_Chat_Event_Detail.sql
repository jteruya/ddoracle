SELECT 
  a."ApplicationId", 
  CAST(b.StartDate AS DATE) AS "Start",
  CAST(b.EndDate AS DATE) AS "End",  
  regexp_replace(a."Event", ',', '', 'g'),
  a."Total Rooms",
  COALESCE(a."% Rooms with any Messages",0.00) AS "% Rooms with any Messages",
  COALESCE(a."% Rooms with 2-way Conversation",0.00) AS "% Rooms with 2-way Conversation",
  COALESCE(a."% Rooms with 1-way Conversation",0.00) AS "% Rooms with 1-way Conversation",
  COALESCE(a."% Rooms with no Conversation",0.00) AS "% Rooms with no Conversation",
  COALESCE(a."% Messages followed by View from Recipient",0.00) AS "% Messages followed by View from Recipient",
  COALESCE(a."% Messages followed by Reply Sent",0.00) AS "% Messages followed by Reply Sent",
  COALESCE(a."Rooms - with any Messages",0.00) AS "Rooms - with any Messages", 
  COALESCE(a."Rooms - with 2-way Conversation",0.00) AS "Rooms - with 2-way Conversation", 
  COALESCE(a."Rooms - with 1-way Conversation",0.00) AS "Rooms - with 1-way Conversation", 
  COALESCE(a."Rooms - with no Conversation",0.00) AS "Rooms - with no Conversation", 
  COALESCE(a."Messages - Sent",0.00) AS "Messages - Sent",
  COALESCE(a."Messages - followed by View from Recipient",0.00) AS "Messages - followed by View from Recipient", 
  COALESCE(a."Messages - followed by Reply Sent",0.00) AS "Messages - followed by Reply Sent"
FROM dashboard.Chat_Agg_Event a
JOIN PUBLIC.AuthDB_Applications b ON a."ApplicationId" = b.ApplicationId 
WHERE a."ApplicationId" NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND b.StartDate <= CURRENT_DATE
ORDER BY b.StartDate DESC