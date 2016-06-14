#!/bin/bash

# ================================================================================================================ -
#
# phd12_login.sh 
# ----------------------
# - Wrapper for all elements that must be run to generate the Product Health Dashboards - Chat page. 
# 
#
# 0. Set the Generic Fields for this script. 
# 1. ETL - Transformation SQL for setting up the static datasets that will be pulled for reports. 
# 2. Email - Runs the Email tool that runs specific SQL to assemble an email that is sent per period. 
# 3. Report - (a) Run the Report SQL, (b) move and transpose the CSVs, (c) and split per report. 
# 4. HTML - Generate the HTML for the Dashboard with any custom insights. 
# 5. Productionalize - Copy the Dashboard elements for use with the Production Web Server. 
#
# ================================================================================================================ -
#  0  #
# === #
# Base fields
kpi_domain="login"
wd="oracle"
etl="${kpi_domain}_etl"
domain_wd="$HOME/${wd}/${kpi_domain}"
#domain_wd="$HOME/repo/${wd}/${kpi_domain}"

# Report fields
kpi_ios_open_login_funnel_devices_monthly_report="KPI_Robin_iOSOpenLoginFunnelDevicesMonthly"
kpi_ios_closed_login_funnel_devices_monthly_report="KPI_Robin_iOSClosedLoginFunnelDevicesMonthly"
kpi_ios_open_login_funnel_monthly_report="KPI_Robin_iOSOpenLoginFunnelMonthly"
kpi_ios_closed_login_funnel_monthly_report="KPI_Robin_iOSClosedLoginFunnelMonthly"
kpi_android_open_login_funnel_devices_monthly_report="KPI_Robin_AndroidOpenLoginFunnelDevicesMonthly"
kpi_android_closed_login_funnel_devices_monthly_report="KPI_Robin_AndroidClosedLoginFunnelDevicesMonthly"
kpi_android_open_login_funnel_monthly_report="KPI_Robin_AndroidOpenLoginFunnelMonthly"
kpi_android_closed_login_funnel_monthly_report="KPI_Robin_AndroidClosedLoginFunnelMonthly"

# Generic Tools/Scripts
run_sql_robin='psql -h 10.223.192.6 -p 5432 -U etl -A -F"," analytics -f '
transpose="python $HOME/tools/transpose.py"
#transpose="python $HOME/repo/tools/transpose.py"
index_insights_fill="python ${kpi_domain_wd}/index_insights_fill.py"
email_reports_wd="$HOME/email_reports"

# Module settings
#email_day=$1 # Set the day that the email will be sent.

# Day of Week
DAYOFWEEK=$(date +"%u")

# ====================================================================================================== ========== 0
echo "================================================================================================="
echo `date` 
echo "Starting script for KPI reports: ${kpi_domain} ..."

# ====================================================================================================== ========== 1
#  1  #
# === #
echo "-------------------------------------------------------------------------------------------------"
echo "TRANSFORMATION ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

#echo "Running $etl.sql."
$run_sql_robin $domain_wd/sql/get_login_metrics.sql
$run_sql_robin $domain_wd/sql/create_device_checklist.sql
$run_sql_robin $domain_wd/sql/get_session_metrics.sql

# ====================================================================================================== ========== 2
#  2  #
# === #
# echo "-------------------------------------------------------------------------------------------------"
# echo "QUERY EMAILER ($kpi_domain_formal) : " `date` 
# echo "-------------------------------------------------------------------------------------------------"
# # 0. Check if the wrapper is set to email on a specific day.
# # 1. Run the KPI SQL to perform the load and drop the values from the table into a CSV for emails.
# # 2. Transpose the query result set. 
# # 3. Send the structured email with any notes about large boosts/drops
# if [[ ! -z "$email_day" ]]; then
# 	if [[ "$email_day" == "Monday" && "$DAYOFWEEK" == "1" ]] || [[ "$email_day" == "Tuesday" && "$DAYOFWEEK" == "2" ]] || [[ "$email_day" == "Wednesday" && "$DAYOFWEEK" == "3" ]] || [[ "$email_day" == "Thursday" && "$DAYOFWEEK" == "4" ]] || [[ "$email_day" == "Friday" && "$DAYOFWEEK" == "5" ]] || [[ "$email_day" == "Saturday" && "$DAYOFWEEK" == "6" ]] || [[ "$email_day" == "Sunday" && "$DAYOFWEEK" == "7" ]] || [[ "$email_day" == "Daily" ]]; then
# 		echo "Sending email today. (Day of the Week: ${DAYOFWEEK})"
# 		$email_reports_wd/./query_emailer.sh $kpi_domain_formal custom
# 	fi
# else
# 	echo "No email is set to be sent."
# fi

# ====================================================================================================== ========== 3a
#  3  #
# === #
echo "-------------------------------------------------------------------------------------------------"
echo "REPORTS - Run the SQL Reports ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

$run_sql_robin $domain_wd/sql/$kpi_ios_open_login_funnel_devices_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_ios_open_login_funnel_devices_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_ios_closed_login_funnel_devices_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_ios_closed_login_funnel_devices_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_ios_open_login_funnel_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_ios_open_login_funnel_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_ios_closed_login_funnel_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_ios_closed_login_funnel_monthly_report.csv

$run_sql_robin $domain_wd/sql/$kpi_android_open_login_funnel_devices_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_android_open_login_funnel_devices_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_android_closed_login_funnel_devices_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_android_closed_login_funnel_devices_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_android_open_login_funnel_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_android_open_login_funnel_monthly_report.csv
$run_sql_robin $domain_wd/sql/$kpi_android_closed_login_funnel_monthly_report.sql | sed \$d | sed 's/\"//g' > $domain_wd/csv/$kpi_android_closed_login_funnel_monthly_report.csv



# ====================================================================================================== ========== 3b
echo "-------------------------------------------------------------------------------------------------"
echo "REPORTS - Move and Transpose the Report Datasets ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

# Transpose the Result Set CSV

# ====================================================================================================== ========== 4
#  4  #
# === #
# echo "-------------------------------------------------------------------------------------------------"
# echo "DASHBOARD - Assemble the HTML ($kpi_domain_formal) : " `date` 
# echo "-------------------------------------------------------------------------------------------------"

# Performing Insight insertion to dashboard HTML
# NONE TO PERFORM

# ====================================================================================================== ========== 5 
#  5  #
# === #
echo "-------------------------------------------------------------------------------------------------"
echo "PRODUCTIONALIZE - Copy Dashboard files for Production ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

cp -rf $domain_wd/index.html /var/www/html/product/dashboards/$kpi_domain/index.html
cp -rf $domain_wd/js/* /var/www/html/product/dashboards/$kpi_domain/js
cp -rf $domain_wd/image/* /var/www/html/product/dashboards/$kpi_domain/image
cp -rf $domain_wd/csv/* /var/www/html/product/dashboards/$kpi_domain/csv

# ====================================================================================================== ========== -
#  6  #
# === #
echo "-------------------------------------------------------------------------------------------------"
echo "CLEANUP - Clean the tables created via ETL ($kpi_domain) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

#echo "Running cleanup_$etl.sql."
# NONE TO PERFORM
