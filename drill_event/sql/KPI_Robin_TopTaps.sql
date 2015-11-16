SELECT Tapped AS "Action", Taps AS "Taps", ROUND(PCT_Taps,2) AS "% of Total Taps"
FROM dashboard.kpi_event_tap_top
WHERE ApplicationId = '0000B092-C9F5-4147-ADBF-3A14EDDFE0E5';