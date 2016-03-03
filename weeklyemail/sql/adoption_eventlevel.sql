\pset footer
\f ','
\a
\o :csvdir/adoption_eventlevel.csv

select week_starting as "Week Of"
     , applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Event Start Date"
     , enddate as "Event End Date"
     , registrants as "Registrants"
     , usersactive as "Active Users"
     , adoption as "Adoption %" 
from dashboard.weekly_adoption_events
where openevent = 0
order by 1,3,4,2;
