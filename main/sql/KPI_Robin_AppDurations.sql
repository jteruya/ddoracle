--Identify the Median Length of In-App Duration per User per Week (for the past 8 weeks)
SELECT YYYY_WW, ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Total_Duration_Minutes) AS NUMERIC),2) AS Median_MinutesPerUser FROM (
SELECT YYYY_WW, UserId, SUM(Duration_Seconds) AS Total_Duration_Seconds, ROUND(CAST(SUM(Duration_Seconds) AS Numeric) / 60,2) AS Total_Duration_Minutes FROM dashboard.App_Durations_Weekly t GROUP BY 1,2
) t GROUP BY 1;

