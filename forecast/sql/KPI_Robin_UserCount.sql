SELECT ROW_NUMBER() OVER (PARTITION BY 1) AS N, CNT, YYYY_MM FROM (
SELECT YYYY_MM, COUNT(*) AS CNT FROM (

SELECT app.ApplicationId, app.Name, app.StartDate, CAST(CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) AS TEXT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS TEXT) AS YYYY_MM, ec.DevicePreference, ec.UserId
FROM EventCube.Agg_Session_Per_AppUserAppTypeId ec
JOIN AuthDB_Applications app ON ec.ApplicationId = app.ApplicationId
AND app.StartDate < '2015-06-30'
AND app.StartDate IS NOT NULL
AND app.StartDate >= CAST(CAST(CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months') AS INT) AS TEXT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_DATE- INTERVAL'13 months') AS INT) < 10 THEN '0' ELSE '' END || CAST(CAST(EXTRACT(MONTH FROM CURRENT_DATE- INTERVAL'13 months') AS INT) AS TEXT) || '-01' AS DATE)
--AND ec.DevicePreference IN ('Android','iPhone','iPad','HTML5')

) t GROUP BY 1 ORDER BY 1
) t
