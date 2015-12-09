SELECT 
  "Year-Month",
  "Active Users",
  CAST(ROUND(100 * CAST("Users Tapped" AS NUMERIC) / CAST("Active Users" AS NUMERIC),2) AS TEXT)||'% ('||CAST("Users Tapped" AS TEXT)||')' AS "% Users Tapped from Active Users",
  CAST(ROUND(100 * CAST("Users completed Web Form" AS NUMERIC) / CAST("Users Tapped" AS NUMERIC),2) AS TEXT)||'% ('||CAST("Users completed Web Form" AS TEXT)||')' AS "% Users completed Web Form from Users Tapped"
FROM dashboard.inapp_user_agg 
ORDER BY 1 DESC;