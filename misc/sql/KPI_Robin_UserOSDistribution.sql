--Get the distribution of OS Types across all Users 
SELECT CASE WHEN AppTypeId = 1 THEN 'iPhone' WHEN AppTypeId = 2 THEN 'iPad' WHEN AppTypeId = 3 THEN 'Android' WHEN AppTypeId = 4 THEN 'HTML5' END AS Typ, YYYY_MM, 
--CNT, SUM(CNT) OVER (PARTITION BY YYYY_MM) AS Total 
ROUND(100 * CAST(CNT AS NUMERIC) / CAST(SUM(CNT) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_CNT
FROM (
        SELECT YYYY_MM, AppTypeId, COUNT(DISTINCT UserId) AS CNT 
        FROM dashboard.kpi_social_metrics_firstsession_os_version
        GROUP BY 1,2
) t
ORDER BY 1,2;
