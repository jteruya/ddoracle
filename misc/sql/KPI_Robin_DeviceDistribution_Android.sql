--Identify the breakdown on Android devices
SELECT MMM_Info, YYYY_MM, SUM(PCT_CNT) FROM (
SELECT
/*
CASE
  WHEN mi.MMM_Info = 'd2vzw,SCH-I535,samsung' THEN 'Samsung Galaxy S3 (Verizon)'
  WHEN mi.MMM_Info = 'hammerhead,Nexus 5,LGE' THEN 'Nexus 5'
  WHEN mi.MMM_Info = 'hltevzw,SM-N900V,samsung' THEN 'Samsung Galaxy Note 3 (Verizon)'
  WHEN mi.MMM_Info = 'jfltespr,SPH-L720,samsung' THEN 'Samsung Galaxy S4 (Sprint)'
  WHEN mi.MMM_Info = 'jfltetmo,SGH-M919,samsung' THEN 'Samsung Galaxy S4 (T-Mobile)'
  WHEN mi.MMM_Info = 'jflteuc,SAMSUNG-SGH-I337,samsung' THEN 'Samsung Galaxy S4 (AT&T)'
  WHEN mi.MMM_Info = 'jfltevzw,SCH-I545,samsung' THEN 'Samsung Galaxy S4 (Verizon)'
  WHEN mi.MMM_Info = 'jfltexx,GT-I9505,samsung' THEN 'Samsung Galaxy S4 (International LTE)'
  WHEN mi.MMM_Info = 'jfveltexx,GT-I9515,samsung' THEN 'Samsung Galaxy S4 (Value Edition)'
  WHEN mi.MMM_Info = 'kltespr,SM-G900P,samsung' THEN 'Samsung Galaxy S5 (Sprint)'
  WHEN mi.MMM_Info = 'kltetmo,SM-G900T,samsung' THEN 'Samsung Galaxy S5 (T-Mobile)'
  WHEN mi.MMM_Info = 'klteuc,SAMSUNG-SM-G900A,samsung' THEN 'Samsung Galaxy S5 (AT&T)'
  WHEN mi.MMM_Info = 'kltevzw,SM-G900V,samsung' THEN 'Samsung Galaxy S5 (Verizon)'
  WHEN mi.MMM_Info = 'kltexx,SM-G900F,samsung' THEN 'Samsung Galaxy S5'
  WHEN mi.MMM_Info = 'm0xx,GT-I9300,samsung' THEN 'Samsung Galaxy S3'
  WHEN mi.MMM_Info = 'obake-maxx_verizon,XT1080,motorola' THEN 'Motorola Droid Ultra Maxx'
  WHEN mi.MMM_Info = 'quark_verizon,XT1254,motorola' THEN 'Motorola Droid Turbo Quark'
  WHEN mi.MMM_Info = 'serranoltexx,GT-I9195,samsung' THEN 'Samsung Galaxy S4 Mini'
  WHEN mi.MMM_Info = 'trltevzw,SM-N910V,samsung' THEN 'Samsung Galaxy Note 4 (Verizon)'
  WHEN mi.MMM_Info = 'zerofltevzw,SM-G920V,samsung' THEN 'Samsung Galaxy S6 (Verizon)'
  ELSE '(untranslated) - ' || REPLACE(mi.MMM_Info,',','-')
END AS MMM_Info,
*/
CASE
  WHEN mi.MMM_Info IN ('hammerhead,Nexus 5,LGE') THEN 'Nexus 5'
  WHEN mi.MMM_Info IN ('m0xx,GT-I9300,samsung','d2vzw,SCH-I535,samsung') THEN 'Samsung Galaxy S3'
  WHEN mi.MMM_Info LIKE 'jf%,samsung' THEN 'Samsung Galaxy S4'
  WHEN mi.MMM_Info LIKE 'klt%,samsung' THEN 'Samsung Galaxy S5'
  WHEN mi.MMM_Info LIKE '%SM%G920%samsung' THEN 'Samsung Galaxy S6'
  WHEN mi.MMM_Info LIKE '%SM%G925%samsung' THEN 'Samsung Galaxy S6 Edge'
  WHEN mi.MMM_Info LIKE '%SM%G930%samsung' THEN 'Samsung Galaxy S7'
  WHEN mi.MMM_Info LIKE '%SM%G935%samsung' THEN 'Samsung Galaxy S7 Edge'  
  WHEN mi.MMM_Info = 'serranoltexx,GT-I9195,samsung' THEN 'Samsung Galaxy S4 Mini'
  WHEN mi.MMM_Info IN ('hltevzw,SM-N900V,samsung') THEN 'Samsung Galaxy Note 3'
  WHEN mi.MMM_Info LIKE '%SM%N910%samsung' THEN 'Samsung Galaxy Note 4'
  WHEN mi.MMM_Info LIKE '%SM%N920%samsung' THEN 'Samsung Galaxy Note 5'  
  WHEN mi.MMM_Info = 'obake-maxx_verizon,XT1080,motorola' THEN 'Motorola Droid Ultra Maxx'
  WHEN mi.MMM_Info = 'quark_verizon,XT1254,motorola' THEN 'Motorola Droid Turbo Quark'
  WHEN mi.MMM_Info LIKE'%kinzie%verizon%XT1585%motorola%' THEN 'Motorola Droid Turbo 2'
  WHEN mi.MMM_Info LIKE '%A0001%OnePlus%' THEN 'OnePlus'
  WHEN mi.MMM_Info LIKE '%Nexus 6%' THEN 'Nexus 6'
  WHEN mi.MMM_Info LIKE '%Nexus 5X%' THEN 'Nexus 5X'

  ELSE '(untranslated) - ' || REPLACE(mi.MMM_Info,',','-')
END AS MMM_Info,
months.YYYY_MM,
COALESCE(pct.PCT_CNT,0) AS PCT_CNT
FROM (SELECT DISTINCT YYYY_MM FROM dashboard.kpi_social_metrics_device_pct) months
JOIN (SELECT DISTINCT OS, MMM_Info FROM dashboard.kpi_social_metrics_device_pct WHERE OS = 'Android') mi ON 1=1
LEFT JOIN dashboard.kpi_social_metrics_device_pct pct ON months.YYYY_MM = pct.YYYY_MM AND mi.MMM_Info = pct.MMM_Info AND mi.OS = pct.OS
) t GROUP BY 1,2 ORDER BY 1,2
