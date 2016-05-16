SELECT 'Views' AS Label, * FROM dashboard.Agg_Fact_Views_per_YYYYMM 
UNION ALL
SELECT 'Actions' AS Label, * FROM dashboard.Agg_Fact_Actions_per_YYYYMM
UNION ALL
SELECT 'Impressions' AS Label, * FROM dashboard.Agg_Fact_Impressions_per_YYYYMM
UNION ALL
SELECT 'Session Start/Ends' AS Label, * FROM dashboard.Agg_Fact_Sessions_per_YYYYMM
UNION ALL
SELECT 'States' AS Label, * FROM dashboard.Agg_Fact_States_per_YYYYMM
UNION ALL
SELECT 'Notifications' AS Label, * FROM dashboard.Agg_Fact_Notifications_per_YYYYMM
UNION ALL
SELECT 'Errors' AS Label, * FROM dashboard.Agg_Fact_Errors_per_YYYYMM
UNION ALL
SELECT 'Checkpoints' AS Label, * FROM dashboard.Agg_Fact_Checkpoints_per_YYYYMM
;
