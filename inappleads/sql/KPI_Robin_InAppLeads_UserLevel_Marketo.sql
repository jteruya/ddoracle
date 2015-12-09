SELECT DISTINCT
  base.Name AS "Event",
  TO_CHAR(base.FirstTap,'YYYY-MM-DD HH24:MI:SS') AS "First tap on App-By-DD",
  TO_CHAR(base.LastTap,'YYYY-MM-DD HH24:MI:SS') AS "Last tap on App-By-DD",
  marketo.Email AS "Email",
  --CASE WHEN marketo.Email IS NOT NULL THEN 'Y' ELSE 'N' END AS "Completed Web Form (In Marketo)", 
  TO_CHAR(marketo.LatestFormFillDate,'YYYY-MM-DD HH24:MI:SS') AS "Completed Web Form",
  marketo.LatestFormFillDate - base.LastTap AS "Time between Last Tap and Last Web Form"
  --marketo.ProgramId
FROM dashboard.inapp_taps base
JOIN kevin.Ratings_GlobalUserDetails gud ON base.Global_User_Id = LOWER(gud.GlobalUserId)
JOIN dashboard.inapp_marketo_leads marketo ON LOWER(gud.EmailAddress) = LOWER(marketo.Email)
WHERE marketo.Email NOT LIKE '%doubledutch.me'
AND marketo.LatestFormFillDate - base.LastTap > INTERVAL'0 seconds'
ORDER BY TO_CHAR(marketo.LatestFormFillDate,'YYYY-MM-DD HH24:MI:SS') DESC
LIMIT 10;