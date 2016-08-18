SELECT * FROM (
SELECT 'All Events' AS EventType
     , CAST(EXTRACT(YEAR FROM StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM StartDate) AS INT) AS YYYY_MM
     , 100.00 * ROUND(MEDIAN(Adoption),2) AS PCT_Adoption
FROM EventCube.EventCubeSummary
WHERE ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND StartDate <= CURRENT_DATE --Only Events that have already started
AND StartDate >= CURRENT_DATE - INTERVAL'13' month
GROUP BY 1,2
UNION
SELECT CASE WHEN EventType = 'Conference (>2:1 session:exhibitor ratio)' THEN 'Conference' WHEN EventType = 'Corporate External' THEN 'Corporate External' WHEN EventType = 'Corporate Internal' THEN 'Corporate Internal' WHEN EventType = 'Expo (<2:1 session:exhibitor ratio)' THEN 'Expo' ELSE 'N/A' END AS EventType
     , CAST(EXTRACT(YEAR FROM StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM StartDate) AS INT) AS YYYY_MM
     , 100.00 * ROUND(MEDIAN(Adoption),2) AS PCT_Adoption
FROM EventCube.EventCubeSummary
WHERE ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND StartDate <= CURRENT_DATE --Only Events that have already started
AND StartDate >= CURRENT_DATE - INTERVAL'13' month
GROUP BY 1,2
) A
WHERE EventType <> 'N/A'
AND PCT_Adoption IS NOT NULL
ORDER BY 1,2
;