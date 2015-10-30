--Transpose for display
SELECT 
base.ApplicationId,
REPLACE(base.Name,',','') AS "Event", 
base.TotalTaps AS "Total Menu Taps",
r1.Tapped || ' - ' || r1.results AS "#1",
r2.Tapped || ' - ' || r2.results AS "#2",
r3.Tapped || ' - ' || r3.results AS "#3",
r4.Tapped || ' - ' || r4.results AS "#4",
r5.Tapped || ' - ' || r5.results AS "#5",
r6.Tapped || ' - ' || r6.results AS "#6",
r7.Tapped || ' - ' || r7.results AS "#7",
r8.Tapped || ' - ' || r8.results AS "#8",
r9.Tapped || ' - ' || r9.results AS "#9",
r10.Tapped || ' - ' || r10.results AS "#10"
FROM (SELECT DISTINCT ApplicationId, Name, TotalTaps FROM dashboard.kpi_event_menutap_top) base
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 1) r1 ON base.ApplicationId = r1.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 2) r2 ON base.ApplicationId = r2.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 3) r3 ON base.ApplicationId = r3.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 4) r4 ON base.ApplicationId = r4.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 5) r5 ON base.ApplicationId = r5.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 6) r6 ON base.ApplicationId = r6.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 7) r7 ON base.ApplicationId = r7.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 8) r8 ON base.ApplicationId = r8.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 9) r9 ON base.ApplicationId = r9.ApplicationId
LEFT JOIN (SELECT ApplicationId, Tapped, CAST(Taps AS TEXT) || ' (' || CAST(ROUND(PCT_Taps,1) AS TEXT) || '%)' AS Results FROM dashboard.kpi_event_menutap_top WHERE RNK = 10) r10 ON base.ApplicationId = r10.ApplicationId
ORDER BY 2
;