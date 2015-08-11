--Identify the Median Length of a Session per Week (for the past 8 weeks)
SELECT YYYY_WW, ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duration_Seconds) AS NUMERIC),2) AS Median_SecondsPerSession FROM (
SELECT
CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || '-' || CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) AS YYYY_WW,
a.*
FROM kevin.KPI_SessionDurations a
JOIN AuthDB_Applications b ON UPPER(a.ApplicationId) = b.ApplicationId
WHERE CAST(EXTRACT(WEEK FROM CURRENT_DATE) AS INT) - CAST(EXTRACT(WEEK FROM b.StartDate) AS INT) <= 8
) t GROUP BY 1;

