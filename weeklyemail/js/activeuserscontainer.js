
$(function () {
    // Create the chart
    $('#activeuserscontainer').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'Active Users Count Trend'
        },
         subtitle: {
            text: 'By Week (All Events)'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Active Users Count'
            }
        },
        colors: ['#90ED7D'],
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
            name: "Active Users",
            colorByPoint: false,
            // data: [{"name":"2015-12-07","drilldown":"2015-12-07","y":50.92}, {"name":"2015-12-14","drilldown":"2015-12-14","y":63.79}, {"name":"2015-12-21","drilldown":"2015-12-21","y":68.42}, {"name":"2015-12-28","drilldown":"2015-12-28","y":96.87}, {"name":"2016-01-01","drilldown":"2016-01-01","y":69.73}, {"name":"2016-01-04","drilldown":"2016-01-04","y":47.71}, {"name":"2016-01-11","drilldown":"2016-01-11","y":64.01}, {"name":"2016-01-18","drilldown":"2016-01-18","y":45.76}, {"name":"2016-01-25","drilldown":"2016-01-25","y":67.05}, {"name":"2016-02-01","drilldown":"2016-02-01","y":38.25}]
            data: [{"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":12984}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":13914}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":29594}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":24191}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":32728}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":27740}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":20209}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":25329}, {"name":"Week of 2016-02-29","drilldown":"Week of 2016-02-29","y":20942}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 9556],["Corporate External", 4160],["Corporate Internal", 13412],["Expo", 2266],["_Unknown", 200]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 2158],["Corporate External", 270],["Corporate Internal", 11183],["Expo", 65],["_Unknown", 238]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 10674],["Corporate External", 3545],["Corporate Internal", 6462],["Expo", 3454],["_Unknown", 1194]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 8657],["Corporate External", 7349],["Corporate Internal", 5144],["Expo", 3136],["_Unknown", 3454]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 21038],["Corporate External", 2063],["Corporate Internal", 7777],["Expo", 1403],["_Unknown", 447]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 8429],["Corporate External", 3112],["Corporate Internal", 6515],["Expo", 39],["_Unknown", 2114]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 2201],["Corporate External", 3797],["Corporate Internal", 12972],["Expo", 4923],["_Unknown", 298]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 3366],["Corporate External", 1046],["Corporate Internal", 7581],["Expo", 805],["_Unknown", 186]]},{"name": "Week of 2016-02-29", "id": "Week of 2016-02-29", "data": [["Conference", 15240],["Corporate External", 1028],["Corporate Internal", 2918],["Expo", 501],["_Unknown", 1255]]}]

        }
    });
});
