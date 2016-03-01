
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
            data: [{"name":"Week of 2015-12-28","drilldown":"Week of 2015-12-28","y":81.72}, {"name":"Week of 2016-01-01","drilldown":"Week of 2016-01-01","y":82.81}, {"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":47.74}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":64.27}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":56.87}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":74.94}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":53.10}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":52.70}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":70.13}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":48.08}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 59.19],["Corporate External", 71.73],["Corporate Internal", 57.78],["Expo", 53.43],["_Unknown", 29.06]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 75.70],["Corporate External", 44.93],["Corporate Internal", 64.30],["Expo", 0],["_Unknown", 40.96]]},{"name": "Week of 2015-12-28", "id": "Week of 2015-12-28", "data": [["Conference", 0],["Corporate External", 0],["Corporate Internal", 81.72],["Expo", 0],["_Unknown", 0]]},{"name": "Week of 2016-01-01", "id": "Week of 2016-01-01", "data": [["Conference", 0],["Corporate External", 0],["Corporate Internal", 82.81],["Expo", 0],["_Unknown", 0]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 64.04],["Corporate External", 77.25],["Corporate Internal", 45.53],["Expo", 0],["_Unknown", 0]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 74.97],["Corporate External", 58.74],["Corporate Internal", 40.96],["Expo", 0],["_Unknown", 71.05]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 47.50],["Corporate External", 68.69],["Corporate Internal", 75.82],["Expo", 28.21],["_Unknown", 51.38]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 51.23],["Corporate External", 79.22],["Corporate Internal", 73.55],["Expo", 0],["_Unknown", 64.66]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 61.04],["Corporate External", 80.34],["Corporate Internal", 78.29],["Expo", 69.36],["_Unknown", 71.52]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 37.34],["Corporate External", 55.88],["Corporate Internal", 50.94],["Expo", 84.21],["_Unknown", 33.33]]}]

        }
    });
});
