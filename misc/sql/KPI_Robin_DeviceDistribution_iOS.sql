--Identify the breakdown on iOS devices
SELECT MMM_Info, YYYY_MM, SUM(PCT_CNT) FROM (
SELECT
--mi.OS,
--mi.MMM_Info,
CASE
  WHEN mi.MMM_Info = 'iPhone8,2' THEN 'iPhone 6s Plus'
  WHEN mi.MMM_Info = 'iPhone8,1' THEN 'iPhone 6s'
  WHEN mi.MMM_Info = 'iPhone7,2' THEN 'iPhone 6'
  WHEN mi.MMM_Info = 'iPhone7,1' THEN 'iPhone 6 Plus'
  WHEN mi.MMM_Info = 'iPhone6,2' THEN 'iPhone 5s'
  WHEN mi.MMM_Info = 'iPhone6,1' THEN 'iPhone 5'
  WHEN mi.MMM_Info IN ('iPhone5,4','iPhone5,3') THEN 'iPhone 5C'
  WHEN mi.MMM_Info IN ('iPhone5,2','iPhone5,1') THEN 'iPhone 5'
  WHEN mi.MMM_Info = 'iPhone4,1' THEN 'iPhone 4s'
  WHEN mi.MMM_Info IN ('iPhone3,3','iPhone3,1') THEN 'iPhone 4'
  WHEN mi.MMM_Info IN ('iPad5,4','iPad5,3') THEN 'iPad Air 2'
  WHEN mi.MMM_Info = 'iPad4,4' THEN 'iPad mini 2'
  WHEN mi.MMM_Info IN ('iPad4,2','iPad4,1') THEN 'iPad Air'
  WHEN mi.MMM_Info IN ('iPad3,6','iPad3,4') THEN 'iPad (4th Gen)'
  WHEN mi.MMM_Info IN ('iPad3,3','iPad3,1') THEN 'iPad (3rd Gen)'
  WHEN mi.MMM_Info = 'iPad2,5' THEN 'iPad mini'
  WHEN mi.MMM_Info IN ('iPad2,2','iPad2,1') THEN 'iPad 2'
  WHEN mi.MMM_Info = 'iPhone8,4' THEN 'iPhone SE'
  ELSE '(untranslated) - ' || REPLACE(mi.MMM_Info,',','-')
END AS MMM_Info,
months.YYYY_MM,
COALESCE(pct.PCT_CNT,0) AS PCT_CNT
FROM (SELECT DISTINCT YYYY_MM FROM dashboard.kpi_social_metrics_device_pct) months
JOIN (SELECT DISTINCT OS, MMM_Info FROM dashboard.kpi_social_metrics_device_pct WHERE OS = 'iOS') mi ON 1=1
LEFT JOIN dashboard.kpi_social_metrics_device_pct pct ON months.YYYY_MM = pct.YYYY_MM AND mi.MMM_Info = pct.MMM_Info AND mi.OS = pct.OS
) t GROUP BY 1,2 ORDER BY 1,2;