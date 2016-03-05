
$(function () {
    // Create the chart
    $('#adoptioncontainer').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'Adoption % Trend'
        },
         subtitle: {
            text: 'By Week (Closed Reg Events Only)'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Adoption %'
            }
        },
        colors: ['#7CB5EC'],
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
            name: "Adoption",
            colorByPoint: false,
            // data: [{"name":"2015-12-07","drilldown":"2015-12-07","y":50.92}, {"name":"2015-12-14","drilldown":"2015-12-14","y":63.79}, {"name":"2015-12-21","drilldown":"2015-12-21","y":68.42}, {"name":"2015-12-28","drilldown":"2015-12-28","y":96.87}, {"name":"2016-01-01","drilldown":"2016-01-01","y":69.73}, {"name":"2016-01-04","drilldown":"2016-01-04","y":47.71}, {"name":"2016-01-11","drilldown":"2016-01-11","y":64.01}, {"name":"2016-01-18","drilldown":"2016-01-18","y":45.76}, {"name":"2016-01-25","drilldown":"2016-01-25","y":67.05}, {"name":"2016-02-01","drilldown":"2016-02-01","y":38.25}]
            data: [{"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":69.08}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":65.01}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":66.23}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":72.03}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":65.20}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":72.13}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":70.14}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":66.61}, {"name":"Week of 2016-02-29","drilldown":"Week of 2016-02-29","y":65.61}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 50.10],["Corporate External", 65.85],["Corporate Internal", 72.69],["Expo", 53.43],["_Unknown", 38.51]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 56.87],["Corporate External", 53.96],["Corporate Internal", 68.64],["Expo", 0],["_Unknown", 55.78]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 59.01],["Corporate External", 76.69],["Corporate Internal", 66.57],["Expo", 28.64],["_Unknown", 88.69]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 72.03],["Corporate External", 60.82],["Corporate Internal", 75.13],["Expo", 0],["_Unknown", 66.73]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 54.57],["Corporate External", 58.28],["Corporate Internal", 72.53],["Expo", 59.82],["_Unknown", 53.48]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 54.37],["Corporate External", 78.29],["Corporate Internal", 75.81],["Expo", 0],["_Unknown", 61.71]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 63.68],["Corporate External", 72.28],["Corporate Internal", 75.81],["Expo", 52.09],["_Unknown", 54.81]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 51.47],["Corporate External", 44.67],["Corporate Internal", 75.20],["Expo", 84.21],["_Unknown", 0]]},{"name": "Week of 2016-02-29", "id": "Week of 2016-02-29", "data": [["Conference", 60.28],["Corporate External", 68.27],["Corporate Internal", 62.69],["Expo", 70.66],["_Unknown", 73.34]]}]

        }
    });
});
