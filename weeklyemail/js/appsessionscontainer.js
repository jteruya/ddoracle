
$(function () {
    // Create the chart
    $('#appsessionscontainer').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'App Session Count'
        },
         subtitle: {
            text: 'By Week (All Events)'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'App Session Count'
            }
        },
        colors: ['#8085E9'],
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
            name: "App Sessions",
            colorByPoint: false,
            // data: [{"name":"2015-12-07","drilldown":"2015-12-07","y":50.92}, {"name":"2015-12-14","drilldown":"2015-12-14","y":63.79}, {"name":"2015-12-21","drilldown":"2015-12-21","y":68.42}, {"name":"2015-12-28","drilldown":"2015-12-28","y":96.87}, {"name":"2016-01-01","drilldown":"2016-01-01","y":69.73}, {"name":"2016-01-04","drilldown":"2016-01-04","y":47.71}, {"name":"2016-01-11","drilldown":"2016-01-11","y":64.01}, {"name":"2016-01-18","drilldown":"2016-01-18","y":45.76}, {"name":"2016-01-25","drilldown":"2016-01-25","y":67.05}, {"name":"2016-02-01","drilldown":"2016-02-01","y":38.25}]
            data: [{"name":"Week of 2016-01-01","drilldown":"Week of 2016-01-01","y":52238}, {"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":563462}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":747222}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":1311681}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":1372664}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":1292840}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":1115430}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":1050461}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":1189674}, {"name":"Week of 2016-02-29","drilldown":"Week of 2016-02-29","y":83868}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 286878],["Corporate External", 100492],["Corporate Internal", 841512],["Expo", 74987],["_Unknown", 7812]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 143877],["Corporate External", 4813],["Corporate Internal", 586542],["Expo", 828],["_Unknown", 11162]]},{"name": "Week of 2016-01-01", "id": "Week of 2016-01-01", "data": [["Conference", 0],["Corporate External", 0],["Corporate Internal", 52091],["Expo", 147],["_Unknown", 0]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 489675],["Corporate External", 161637],["Corporate Internal", 364289],["Expo", 93261],["_Unknown", 80812]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 380873],["Corporate External", 228197],["Corporate Internal", 299935],["Expo", 49309],["_Unknown", 157116]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 654176],["Corporate External", 70754],["Corporate Internal", 466274],["Expo", 69576],["_Unknown", 32060]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 326379],["Corporate External", 223535],["Corporate Internal", 397083],["Expo", 291],["_Unknown", 103173]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 116335],["Corporate External", 263127],["Corporate Internal", 729792],["Expo", 245616],["_Unknown", 17794]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 160413],["Corporate External", 28375],["Corporate Internal", 356587],["Expo", 13293],["_Unknown", 4794]]},{"name": "Week of 2016-02-29", "id": "Week of 2016-02-29", "data": [["Conference", 4131],["Corporate External", 680],["Corporate Internal", 63767],["Expo", 0],["_Unknown", 15290]]}]

        }
    });
});
