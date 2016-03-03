\pset footer
\f ','
\a
\o :csvdir/appsessions_eventlevel.csv

select week_starting as "Week Of"
     , applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Event Start Date"
     , enddate as "Event End Date"
     , eventtype as "Event Type"
     , case
          when openevent = 1 then 'Open Reg Event'
          else 'Closed Reg Event'
       end as "Event Reg Type"
     , sessions as "Sessions"
from dashboard.weekly_adoption_events
order by 1,3,4,2;
