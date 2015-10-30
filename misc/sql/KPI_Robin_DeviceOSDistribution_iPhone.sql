--Get the distribution of OS Types across all Users 
SELECT 
CASE 
  WHEN AppTypeId = 1 THEN 'iPhone (' || DeviceOSVersion || ')' 
  WHEN AppTypeId = 2 THEN 'iPad (' || DeviceOSVersion || ')' 
  WHEN AppTypeId = 3 THEN 'Android (' || DeviceOSVersion || ')' 
  WHEN AppTypeId = 4 THEN 'HTML5 (' || DeviceOSVersion || ')' 
END AS Typ, YYYY_MM, 
--CNT, SUM(CNT) OVER (PARTITION BY YYYY_MM) AS Total 
ROUND(100 * CAST(CNT AS NUMERIC) / CAST(SUM(CNT) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_CNT
FROM (
        SELECT YYYY_MM, AppTypeId, DeviceOSVersion, COUNT(DISTINCT GlobalUserId) AS CNT 
        FROM dashboard.kpi_social_metrics_firstglobalactivityfeed_views
        WHERE AppTypeId IN (1)
        GROUP BY 1,2,3
) t
ORDER BY 1,2;
