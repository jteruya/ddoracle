--Get the List of Sessions and their related Metadata
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_session_os_version;
CREATE TABLE dashboard.kpi_social_metrics_session_os_version AS
SELECT *, CAST(EXTRACT(YEAR FROM Created) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM Created) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM Created) AS INT) AS YYYY_MM FROM (
SELECT 
App_Type_Id AS AppTypeId, 
Binary_Version AS BinaryVersion,
CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END AS Created
FROM PUBLIC.Fact_Sessions_Old
WHERE CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END <= CURRENT_DATE --Only Session that have started in past 13 months
AND CASE WHEN Metrics_Type_Id = 1 THEN Start_Date WHEN Metrics_Type_Id = 2 THEN End_Date END >= CURRENT_DATE - INTERVAL'13 months') t;

CREATE INDEX ndx_kpi_social_metrics_session_os_version ON dashboard.kpi_social_metrics_session_os_version(YYYY_MM,AppTypeId);


