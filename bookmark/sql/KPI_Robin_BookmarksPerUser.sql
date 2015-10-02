--Per Month, use the full counts of Active Users and Bookmarks to identify Bookmarks per Active User
SELECT base.YYYY_MM, ROUND(CAST(COALESCE(bookmarks.Bookmarks,0) AS NUMERIC) / CAST(base.ActiveAttendees AS NUMERIC),2) AS BookmarksPerActiveUser

FROM (
--Identify count of Active Users per Month
SELECT 
CAST(EXTRACT(YEAR FROM base.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) AS YYYY_MM,
COUNT(*) AS ActiveAttendees
FROM AuthDB_Applications base
JOIN EventCube.Agg_Session_Per_AppUser agg ON base.ApplicationId = agg.ApplicationId
WHERE base.StartDate <= CURRENT_DATE --Only Events that have already started
AND base.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND base.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
GROUP BY 1
) base

LEFT JOIN (
--Identify count of Bookmarks made per Month
SELECT 
CAST(EXTRACT(YEAR FROM base.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) AS YYYY_MM,
COUNT(*) AS Bookmarks
FROM AuthDB_Applications base
JOIN Ratings_UserFavorites uf ON base.ApplicationId = uf.ApplicationId
WHERE base.StartDate <= CURRENT_DATE --Only Events that have already started
AND base.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND base.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND (uf.IsImported = 'false') --OR (uf.IsImported = 'true')
GROUP BY 1
) bookmarks ON base.YYYY_MM = bookmarks.YYYY_MM

ORDER BY 1