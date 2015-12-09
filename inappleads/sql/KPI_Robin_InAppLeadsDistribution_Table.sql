SELECT 
  YYYY_MM AS "Year-Month", 
  COUNT(*) AS "Total Events", 
  CAST(ROUND(100 * CAST(SUM(CASE WHEN InApp_Ind = 'ON' THEN 1 ELSE 0 END) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS TEXT)||'%  ('||CAST(SUM(CASE WHEN InApp_Ind = 'ON' THEN 1 ELSE 0 END) AS TEXT)||' events)' AS "Events w/ App-By-DoubleDutch ON"
FROM (
        SELECT 
          a.ApplicationId, 
          CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM , 
          app.Name, 
          CASE WHEN a.Selected = 'true' THEN 'ON' ELSE 'OFF' END AS InApp_Ind
        FROM PUBLIC.Ratings_ApplicationConfigGridItems a
        JOIN PUBLIC.AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
        WHERE Title IN ('App By DoubleDutch','App by DoubleDutch','App by/par DoubleDutch')
        AND a.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
        AND StartDate <= CURRENT_DATE --Only Events that have started in past 13 months
        AND StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP)
) t 
GROUP BY 1
ORDER BY 1 DESC;