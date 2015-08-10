/*
--Daily Session Median values
SELECT DT, MEDIAN(Sessions) FROM (
SELECT CAST(TS AS Date) AS DT, UserId, COUNT(*) AS Sessions
FROM kevin.Session_StartEnds
WHERE TS_Type = 'Start'
AND TS >= '2015-04-01 00:00:00'
GROUP BY 1,2
) t GROUP BY 1 ORDER BY 1 ASC

--Monthly Session Median values
SELECT YYYY_MM, MEDIAN(Sessions) FROM (
SELECT YYYY_MM, UserId, COUNT(*) AS Sessions
FROM kevin.Session_StartEnds
WHERE TS_Type = 'Start'
AND YYYY_MM >= '2015-04'
GROUP BY 1,2
) t GROUP BY 1 ORDER BY 1 ASC
*/

--Bucketing per Month for past 4 months (Normalizing Distribution per each Month)
SELECT * FROM (
SELECT DISTINCT YYYY_MM, Sessions, ROUND(100 * CAST(COUNT(*) OVER (PARTITION BY YYYY_MM, Sessions) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_In_Bucket FROM (
SELECT YYYY_MM, UserId, COUNT(*) AS Sessions
FROM kevin.Session_StartEnds
WHERE TS_Type = 'Start'
AND TS >= CAST(CAST(EXTRACT(YEAR FROM CAST(CURRENT_DATE AS TIMESTAMP) - INTERVAL'4 months') AS TEXT) || '-' || CASE WHEN EXTRACT(MONTH FROM CAST(CURRENT_DATE AS TIMESTAMP) - INTERVAL'4 months') < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM CAST(CURRENT_DATE AS TIMESTAMP) - INTERVAL'4 months') AS TEXT) || '-01 00:00:00' AS TIMESTAMP)
GROUP BY 1,2
) t 
) t WHERE t.PCT_In_Bucket > 0.5
ORDER BY YYYY_MM, Sessions 