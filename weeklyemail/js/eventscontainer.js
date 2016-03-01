
$(function () {
    // Create the chart
    $('#eventscontainer').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'Event Count Trend'
        },
         subtitle: {
            text: 'By Week (All Events)'
        }, 
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Event Count'
            }

        },
        colors: ['#F7A35C'],
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
            name: "Events",
            colorByPoint: false,
            // data: [{"name":"2015-12-07","drilldown":"2015-12-07","y":50.92}, {"name":"2015-12-14","drilldown":"2015-12-14","y":63.79}, {"name":"2015-12-21","drilldown":"2015-12-21","y":68.42}, {"name":"2015-12-28","drilldown":"2015-12-28","y":96.87}, {"name":"2016-01-01","drilldown":"2016-01-01","y":69.73}, {"name":"2016-01-04","drilldown":"2016-01-04","y":47.71}, {"name":"2016-01-11","drilldown":"2016-01-11","y":64.01}, {"name":"2016-01-18","drilldown":"2016-01-18","y":45.76}, {"name":"2016-01-25","drilldown":"2016-01-25","y":67.05}, {"name":"2016-02-01","drilldown":"2016-02-01","y":38.25}]
            data: [{"name":"Week of 2015-12-28","drilldown":"Week of 2015-12-28","y":2}, {"name":"Week of 2016-01-01","drilldown":"Week of 2016-01-01","y":4}, {"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":32}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":56}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":55}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":59}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":57}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":48}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":39}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":13}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 8],["Corporate External", 4],["Corporate Internal", 25],["Expo", 1],["_Unknown", 3]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 6],["Corporate External", 5],["Corporate Internal", 36],["Expo", 1],["_Unknown", 4]]},{"name": "Week of 2015-12-28", "id": "Week of 2015-12-28", "data": [["Conference", 1],["Corporate External", 1],["Corporate Internal", 1],["Expo", 1],["_Unknown", 1]]},{"name": "Week of 2016-01-01", "id": "Week of 2016-01-01", "data": [["Conference", 1],["Corporate External", 1],["Corporate Internal", 3],["Expo", 1],["_Unknown", 1]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 1],["Corporate External", 2],["Corporate Internal", 7],["Expo", 1],["_Unknown", 1]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 9],["Corporate External", 4],["Corporate Internal", 18],["Expo", 1],["_Unknown", 3]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 10],["Corporate External", 6],["Corporate Internal", 25],["Expo", 3],["_Unknown", 3]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 5],["Corporate External", 6],["Corporate Internal", 14],["Expo", 1],["_Unknown", 5]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 6],["Corporate External", 9],["Corporate Internal", 33],["Expo", 4],["_Unknown", 2]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 4],["Corporate External", 2],["Corporate Internal", 17],["Expo", 1],["_Unknown", 1]]}]

        }
    });
});
