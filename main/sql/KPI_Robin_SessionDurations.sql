--Identify the Median Length of a Session per Week (for the past 8 weeks)
SELECT YYYY_WW, ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duration_Seconds) AS NUMERIC),2) AS Median_SecondsPerSession 
FROM dashboard.Session_Durations_Weekly 
GROUP BY 1
ORDER BY 1;
