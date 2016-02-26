#!/bin/sh

# Base fields
kpi_domain="weeklyemail"
wd="oracle"
etl="${kpi_domain}_etl"
domain_wd="$HOME/${wd}/${kpi_domain}"

ROBIN="psql -h 10.223.192.6 -U etl -d analytics"

# Get Events Population
cat $domain_wd/sql/create_weekly_adoption_events.sql | $ROBIN

# Adoption Chart
cat $domain_wd/sql/adoption_weeklevel.sql | $ROBIN
cat $domain_wd/sql/adoption_eventtypelevel.sql | $ROBIN

# Active Users Chart
cat $domain_wd/sql/activeusers_weeklevel.sql | $ROBIN
cat $domain_wd/sql/activeusers_eventtypelevel.sql | $ROBIN

# Events Chart
cat $domain_wd/sql/events_weeklevel.sql | $ROBIN
cat $domain_wd/sql/events_eventtypelevel.sql | $ROBIN

# App Sessions
cat $domain_wd/sql/appsessions_weeklevel.sql | $ROBIN
cat $domain_wd/sql/appsessions_eventtypelevel.sql | $ROBIN

# Generate JSON Data 
python $wd_domain/columncharttemplate.py adoption_weeklevel.json Adoption adoption_eventtypelevel.json adoptioncontainer.js "Adoption % Trend" "By Week (Closed Reg Events Only)" "Adoption %" "#7CB5EC"
python $wd_domain/columncharttemplate.py activeusers_weeklevel.json "Active Users" activeusers_eventtypelevel.json activeuserscontainer.js "Active Users Count Trend" "By Week (All Events)" "Active Users Count" "#90ED7D"
python $wd_domain/columncharttemplate.py events_weeklevel.json "Events" events_eventtypelevel.json eventscontainer.js "Event Count Trend" "By Week (All Events)" "Event Count" "#F7A35C"
python $wd_domain/columncharttemplate.py appsessions_weeklevel.json "App Sessions" appsessions_eventtypelevel.json appsessionscontainer.js "App Session Count" "By Week (All Events)" "App Session Count" "#8085E9"

# Copy to Web Server
cp -rf $domain_wd/index.html /var/www/html/product/dashboards/$kpi_domain/index.html
cp -rf $domain_wd/js/* /var/www/html/product/dashboards/$kpi_domain/js
cp -rf $domain_wd/image/* /var/www/html/product/dashboards/$kpi_domain/image
cp -rf $domain_wd/csv/* /var/www/html/product/dashboards/$kpi_domain/csv
