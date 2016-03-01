\set START  current_date - 60
\set END    current_date - 1

\t
\pset footer
\a
\f

drop table if exists dashboard.weekly_adoption_events;
create table dashboard.weekly_adoption_events as 
select w.week_starting
     , e.*
from eventcube.eventcubesummary e
join (select wk.*
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= :END and date >= :START) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek) w
on e.startdate = w.date
and e.enddate <= :END