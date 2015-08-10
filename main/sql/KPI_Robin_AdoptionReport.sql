--Per Month, what is the Median Adoption across events that started in that Month
SELECT YYYY_MM, 100*ROUND(MEDIAN(PCT_Adoption),2) FROM (

--Full List of all Closed Registration Events and their Adoption Rates
SELECT ApplicationId, Name, StartDate, 
CAST(EXTRACT(YEAR FROM StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM StartDate) AS INT) AS YYYY_MM,
COUNT(*) AS ListedUsers, SUM(ActiveUserInd) AS ActiveListedUsers, 
CAST(SUM(ActiveUserInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Adoption
FROM (

--Full List of all Attendees per Event and flags to indicate if they had a Session
SELECT app.ApplicationId, app.Name, CAST(app.StartDate AS Date) AS StartDate, u.UserId, CASE WHEN aspa.UserId IS NOT NULL THEN 1 ELSE 0 END AS ActiveUserInd
FROM AuthDB_Applications app
JOIN AuthDB_IS_Users u ON app.ApplicationId = u.ApplicationId
LEFT JOIN EventCube.Agg_Session_Per_AppUser aspa ON app.ApplicationId = aspa.ApplicationId AND u.UserId = aspa.UserId --List of Users with a Session per Application
WHERE app.CanRegister = 'false' --Closed Reg Events
AND u.IsDisabled = 0 --Only existing Attendees in the list
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Filter out Test Events

) t 
WHERE StartDate <= CURRENT_DATE --Only Events that have already started
AND StartDate >= CURRENT_DATE - INTERVAL'13 months'
GROUP BY 1,2,3

) t 

GROUP BY 1 ORDER BY 1