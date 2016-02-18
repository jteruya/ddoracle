#!/bin/bash

# monitor_metricLoad.sh 
# - Wrapper for exposing the status of our latest Client Metric Loads on Robin.

# Base fields
kpi_domain="monitor_metricLoad"
wd="oracle"
etl="${kpi_domain}_etl"
domain_wd="$HOME/${wd}/${kpi_domain}"

# Report fields
monitor_report="monitor_report"

# Generic Tools/Scripts
run_sql_robin='psql -h 10.223.192.6 -p 5432 -U etl -A -F"," analytics -f '

echo "================================================================================================="
echo `date` 
echo "Starting script: ${kpi_domain} ..."

$run_sql_robin $domain_wd/sql/$monitor_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$monitor_report.csv 

echo "-------------------------------------------------------------------------------------------------"
echo "PRODUCTIONALIZE - Copy Dashboard files for Production ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

# cp -rf $domain_wd/index.html /var/www/html/product/dashboards/$kpi_domain/index.html
# cp -rf $domain_wd/image/* /var/www/html/product/dashboards/$kpi_domain/image
# cp -rf $domain_wd/csv/* /var/www/html/product/dashboards/$kpi_domain/csv
