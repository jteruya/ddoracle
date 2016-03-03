\set START  current_date - 60
\set END    current_date - 1

\t
\pset footer
\a
\f
-- \o /var/www/html/secondside/workspace/json/level_1.json
\o :jsondir/adoption_weeklevel.json

select
  json_agg(row_to_json(s)) "data"
from
( select
    'Week of ' || week_starting "name",
    'Week of ' || week_starting drilldown,
    round(100*sum(adoption*registrants)/sum(registrants),2) y
  from dashboard.weekly_adoption_events
  where openevent = 0
  and registrants > 0
  group by 1,2
  order by 1
) s
;

\t 
\f ','
\o :csvdir/adoption_weeklevel.csv

select
   week_starting as "Week Of",
   round(100*sum(adoption*registrants)/sum(registrants),2) as "Adoption %"
from dashboard.weekly_adoption_events
where openevent = 0
and registrants > 0
group by 1
order by 1;
