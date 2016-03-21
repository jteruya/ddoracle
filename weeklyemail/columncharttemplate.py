#!/usr/bin/python
import sys
import os

# wd = '/var/www/html/secondside/workspace'
#wd = '/home/datadawgs/oracle/weeklyemail'
wd = os.getcwd() + '/oracle/weeklyemail'

level1_file=sys.argv[1]
level1_series = sys.argv[2]
level2_file=sys.argv[3]
outputfile = sys.argv[4]
title = sys.argv[5]
subtitle = sys.argv[6]
yaxistitle = sys.argv[7]
color = sys.argv[8]

template = '''
$(function () {
    // Create the chart
    $('#%s').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: '%s'
        },
         subtitle: {
            text: '%s'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: '%s'
            }
        },
        colors: ['%s'],
        legend: {
            enabled: false
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: false
                }
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>'
        },
        series: [{
            name: "%s",
            colorByPoint: false,
            // data: [{"name":"2015-12-07","drilldown":"2015-12-07","y":50.92}, {"name":"2015-12-14","drilldown":"2015-12-14","y":63.79}, {"name":"2015-12-21","drilldown":"2015-12-21","y":68.42}, {"name":"2015-12-28","drilldown":"2015-12-28","y":96.87}, {"name":"2016-01-01","drilldown":"2016-01-01","y":69.73}, {"name":"2016-01-04","drilldown":"2016-01-04","y":47.71}, {"name":"2016-01-11","drilldown":"2016-01-11","y":64.01}, {"name":"2016-01-18","drilldown":"2016-01-18","y":45.76}, {"name":"2016-01-25","drilldown":"2016-01-25","y":67.05}, {"name":"2016-02-01","drilldown":"2016-02-01","y":38.25}]
            data: %s
        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: %s
        }
    });
});
'''
#with open(wd + '/json/level_1.json') as d:
with open(wd + '/json/' + level1_file) as d:
  data = d.read()
with open(wd + '/json/' + level2_file) as s:
  series = s.read()
with open(wd + '/js/' + outputfile,'w') as i:
  i.write(template % (outputfile.split('.', 1)[0],title,subtitle,yaxistitle,color,level1_series,data,series))

