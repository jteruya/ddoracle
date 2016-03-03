\set START  current_date - 60
\set END    current_date - 1

create temporary table eventtypelevel as 
select
   'Week of ' || spine.week_starting "name",
   'Week of ' || spine.week_starting id,
    spine.eventtype,
    sum(case when usersactive is not null then usersactive else 0 end) y
from (select week.week_starting
           , eventtype.eventtype  
      from (select distinct week_starting from dashboard.weekly_adoption_events) week
      join (select distinct case when eventtype = '' then '_Unknown' else trim(split_part(eventtype,'(',1)) end eventtype from dashboard.weekly_adoption_events) eventtype
      on 1 = 1) spine 
left join (select week_starting
                , case when eventtype = '' then '_Unknown' else trim(split_part(eventtype,'(',1)) end eventtype
                , usersactive
           from dashboard.weekly_adoption_events) events 
on spine.eventtype = events.eventtype and spine.week_starting = events.week_starting
group by 1,2,3
order by 1,2,3;  

\t
\pset footer
\a
\f
-- \o /var/www/html/secondside/workspace/json/level_2.json
\o :jsondir/activeusers_eventtypelevel.json

select
  '[' || string_agg(series,',') || ']' series
from
( select
    '{"name": "' || name || '", "id": "' || id || '", "data": ' || data || '}' series
  from
  ( select
      name,
      id,
      replace('[' || string_agg('[''' || eventtype || ''', ' || y::text || ']',',') || ']','''','"') "data"
    from eventtypelevel s
    group by 1,2
  ) s
) s
;

\t
\f ','
\o :csvdir/activeusers_eventtypelevel.csv

select name as "Week Of"
     , eventtype as "Event Type"
     , y as "Active Users Count"
from eventtypelevel;
