\set START  current_date - 60
\set END    current_date - 1

\t
\pset footer
\a
\f
-- \o /var/www/html/secondside/workspace/json/level_1.json
\o :jsondir/appsessions_weeklevel.json

select
  json_agg(row_to_json(s)) "data"
from
( select
    'Week of ' || week_starting "name",
    'Week of ' || week_starting drilldown,
    sum(sessions) y
  from dashboard.weekly_adoption_events
  group by 1,2
  order by 1
) s
;

\t 
\f ','
\o :csvdir/appsessions_weeklevel.csv

select
   week_starting as "Week Of",
   sum(sessions) as "App Sessions Count"
from dashboard.weekly_adoption_events
group by 1
order by 1;
