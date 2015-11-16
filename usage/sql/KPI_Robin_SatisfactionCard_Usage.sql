SELECT * FROM (
SELECT '% of Active Users viewed Satisfaction Card' AS KPI, YYYY_MM, --COUNT(*) AS "Active Users", SUM(Impression_Ind) AS "Active Users - View Satisfaction Card", SUM(Tap_Ind) AS "Active Users - Tap Satisfaction Card",
ROUND(100 * CAST(SUM(Impression_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS PCT_Users
FROM dashboard.SatisfactionCard_Attendees
GROUP BY 1,2

UNION ALL

SELECT '% of Active Users tapped Satisfaction Card' AS KPI, YYYY_MM, --COUNT(*) AS "Active Users", SUM(Impression_Ind) AS "Active Users - View Satisfaction Card", SUM(Tap_Ind) AS "Active Users - Tap Satisfaction Card",
ROUND(100 * CAST(SUM(Tap_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS PCT_Users
FROM dashboard.SatisfactionCard_Attendees
GROUP BY 1,2

UNION ALL

SELECT '% (Conversion Rate)' AS KPI, YYYY_MM, --COUNT(*) AS "Active Users", SUM(Impression_Ind) AS "Active Users - View Satisfaction Card", SUM(Tap_Ind) AS "Active Users - Tap Satisfaction Card",
ROUND(100 * CAST(SUM(Tap_Ind) AS NUMERIC) / CAST(SUM(Impression_Ind) AS NUMERIC),2) AS PCT_Users
FROM dashboard.SatisfactionCard_Attendees
GROUP BY 1,2
) t ORDER BY 1,2