-- Out of all taps, which attendees used the same email address for their login and webform?
SELECT DISTINCT
  base.Name AS "Event",
  TO_CHAR(base.FirstTap,'YYYY-MM-DD HH24:MI:SS') AS "First tap on App-By-DD",
  TO_CHAR(base.LastTap,'YYYY-MM-DD HH24:MI:SS') AS "Last tap on App-By-DD",
  gud.EmailAddress AS "Email",
  CASE WHEN marketo.Email IS NOT NULL THEN 'Y' ELSE 'N' END AS "Completed Web Form (In Marketo)", 
  TO_CHAR(marketo.LatestFormFillDate,'YYYY-MM-DD HH24:MI:SS') AS "Completed Web Form",
  marketo.LatestFormFillDate - base.FirstTap AS "Time between First Tap and Last Web Form",
  marketo.LatestFormFillDate - base.LastTap AS "Time between Last Tap and Last Web Form",
  marketo.ProgramId
FROM dashboard.inapp_taps base
JOIN kevin.Ratings_GlobalUserDetails gud ON base.Global_User_Id = LOWER(gud.GlobalUserId)
LEFT JOIN dashboard.inapp_marketo_leads marketo ON LOWER(gud.EmailAddress) = LOWER(marketo.Email)
ORDER BY CASE WHEN marketo.Email IS NOT NULL THEN 'Y' ELSE 'N' END DESC, TO_CHAR(marketo.LatestFormFillDate,'YYYY-MM-DD HH24:MI:SS') DESC