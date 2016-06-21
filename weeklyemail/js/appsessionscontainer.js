
$(function () {
    // Create the chart
    $('#appsessionscontainer').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'App Session Count Trend'
        },
         subtitle: {
            text: 'By Week (All US Server Events)'
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
            data: [{"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":564646}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":716091}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":1307196}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":1368949}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":1262477}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":1098713}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":1049765}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":1254192}, {"name":"Week of 2016-02-29","drilldown":"Week of 2016-02-29","y":908821}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 286726],["Corporate External", 100668],["Corporate Internal", 837921],["Expo", 74295],["_Unknown", 7586]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 116169],["Corporate External", 4811],["Corporate Internal", 584966],["Expo", 828],["_Unknown", 9317]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 498931],["Corporate External", 177998],["Corporate Internal", 381916],["Expo", 99860],["_Unknown", 95487]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 375962],["Corporate External", 228443],["Corporate Internal", 287480],["Expo", 49151],["_Unknown", 157677]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 662003],["Corporate External", 70756],["Corporate Internal", 439306],["Expo", 69652],["_Unknown", 20760]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 326920],["Corporate External", 222693],["Corporate Internal", 398412],["Expo", 293],["_Unknown", 101447]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 116267],["Corporate External", 262610],["Corporate Internal", 732016],["Expo", 245421],["_Unknown", 12635]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 160346],["Corporate External", 28163],["Corporate Internal", 358014],["Expo", 13317],["_Unknown", 4806]]},{"name": "Week of 2016-02-29", "id": "Week of 2016-02-29", "data": [["Conference", 650246],["Corporate External", 50314],["Corporate Internal", 142977],["Expo", 21636],["_Unknown", 43648]]}]

        }
    });
});
