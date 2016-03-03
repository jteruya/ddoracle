
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
            data: [{"name":"Week of 2016-01-01","drilldown":"Week of 2016-01-01","y":917}, {"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":13014}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":14604}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":29921}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":24429}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":33116}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":28606}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":20434}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":24614}, {"name":"Week of 2016-02-29","drilldown":"Week of 2016-02-29","y":2742}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 9589],["Corporate External", 4161],["Corporate Internal", 13660],["Expo", 2301],["_Unknown", 210]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 2592],["Corporate External", 271],["Corporate Internal", 11270],["Expo", 65],["_Unknown", 406]]},{"name": "Week of 2016-01-01", "id": "Week of 2016-01-01", "data": [["Conference", 0],["Corporate External", 0],["Corporate Internal", 893],["Expo", 24],["_Unknown", 0]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 10696],["Corporate External", 3120],["Corporate Internal", 6426],["Expo", 3436],["_Unknown", 936]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 9267],["Corporate External", 7397],["Corporate Internal", 5340],["Expo", 3145],["_Unknown", 3457]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 21084],["Corporate External", 2068],["Corporate Internal", 8024],["Expo", 1408],["_Unknown", 532]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 8488],["Corporate External", 3170],["Corporate Internal", 6537],["Expo", 39],["_Unknown", 2200]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 2218],["Corporate External", 3838],["Corporate Internal", 12980],["Expo", 4945],["_Unknown", 448]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 3381],["Corporate External", 1055],["Corporate Internal", 7587],["Expo", 805],["_Unknown", 186]]},{"name": "Week of 2016-02-29", "id": "Week of 2016-02-29", "data": [["Conference", 266],["Corporate External", 52],["Corporate Internal", 1893],["Expo", 0],["_Unknown", 531]]}]

        }
    });
});
