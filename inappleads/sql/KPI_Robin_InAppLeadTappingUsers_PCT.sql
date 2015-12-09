SELECT 
  "Year-Month",
  ROUND(100 * CAST("Users Tapped" AS NUMERIC) / CAST("Active Users" AS NUMERIC),2) AS "% Users Tapped"
FROM dashboard.inapp_user_agg 
ORDER BY 1