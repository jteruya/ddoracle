--Identify the breakdown on Menu Item taps
SELECT
mi.MenuItem,
months.YYYY_MM,
COALESCE(pct.PCT_MenuItemTaps,0) AS PCT_MenuItemTaps
FROM (SELECT DISTINCT YYYY_MM FROM dashboard.kpi_social_metrics_menuitemtaps_pct) months
JOIN (SELECT DISTINCT MenuItem FROM dashboard.kpi_social_metrics_menuitemtaps_pct) mi ON 1=1
LEFT JOIN dashboard.kpi_social_metrics_menuitemtaps_pct pct ON months.YYYY_MM = pct.YYYY_MM AND mi.MenuItem = pct.MenuItem
ORDER BY 1,2