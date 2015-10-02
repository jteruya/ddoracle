SELECT * FROM (

--Per Month, use the full counts of Active Users and Bookmarking Users to identify the % of Users Bookmarking
SELECT '1+ bookmarks' AS Type, base.YYYY_MM, CASE WHEN bookmarks.UserBookmarking > base.ActiveAttendees THEN 100 ELSE 100 * ROUND(CAST(COALESCE(bookmarks.UserBookmarking,0) AS NUMERIC) / CAST(base.ActiveAttendees AS NUMERIC),2) END AS PCT_UsersBookmarking

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
--Identify count of Users Bookmarking per Month
SELECT 
CAST(EXTRACT(YEAR FROM base.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) AS YYYY_MM,
COUNT(DISTINCT UserId) AS UserBookmarking
FROM AuthDB_Applications base
JOIN Ratings_UserFavorites uf ON base.ApplicationId = uf.ApplicationId
WHERE base.StartDate <= CURRENT_DATE --Only Events that have already started
AND base.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND base.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND (uf.IsImported = 'false') --OR (uf.IsImported = 'true')
GROUP BY 1
) bookmarks ON base.YYYY_MM = bookmarks.YYYY_MM

UNION ALL

--Per Month, use the full counts of Active Users and Bookmarking Users to identify the % of Users Bookmarking 2+ Items
SELECT '2+ bookmarks' AS Type, base.YYYY_MM, CASE WHEN bookmarks.UserBookmarking2Plus > base.ActiveAttendees THEN 100 ELSE 100 * ROUND(CAST(COALESCE(bookmarks.UserBookmarking2Plus,0) AS NUMERIC) / CAST(base.ActiveAttendees AS NUMERIC),2) END AS PCT_UsersBookmarking

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
--Identify count of Users Bookmarking 2+ items per Month
SELECT YYYY_MM, COUNT(DISTINCT UserId) AS UserBookmarking2Plus
FROM (
SELECT
CAST(EXTRACT(YEAR FROM base.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) AS YYYY_MM,
UserId,
COUNT(*) AS Bookmarks
FROM AuthDB_Applications base
JOIN Ratings_UserFavorites uf ON base.ApplicationId = uf.ApplicationId
WHERE base.StartDate <= CURRENT_DATE --Only Events that have already started
AND base.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND base.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND (uf.IsImported = 'false') --OR (uf.IsImported = 'true')
GROUP BY 1,2
HAVING COUNT(*) >= 2
) t GROUP BY 1
) bookmarks ON base.YYYY_MM = bookmarks.YYYY_MM

UNION ALL

--Per Month, use the full counts of Active Users and Bookmarking Users to identify the % of Users Bookmarking 10+ Items
SELECT '10+ bookmarks' AS Type, base.YYYY_MM, CASE WHEN bookmarks.UserBookmarking10Plus > base.ActiveAttendees THEN 100 ELSE 100 * ROUND(CAST(COALESCE(bookmarks.UserBookmarking10Plus,0) AS NUMERIC) / CAST(base.ActiveAttendees AS NUMERIC),2) END AS PCT_UsersBookmarking

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
--Identify count of Users Bookmarking 10+ items per Month
SELECT YYYY_MM, COUNT(DISTINCT UserId) AS UserBookmarking10Plus
FROM (
SELECT
CAST(EXTRACT(YEAR FROM base.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM base.StartDate) AS INT) AS YYYY_MM,
UserId,
COUNT(*) AS Bookmarks
FROM AuthDB_Applications base
JOIN Ratings_UserFavorites uf ON base.ApplicationId = uf.ApplicationId
WHERE base.StartDate <= CURRENT_DATE --Only Events that have already started
AND base.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND base.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND (uf.IsImported = 'false') --OR (uf.IsImported = 'true')
GROUP BY 1,2
HAVING COUNT(*) >= 10
) t GROUP BY 1
) bookmarks ON base.YYYY_MM = bookmarks.YYYY_MM

) t ORDER BY 1,2