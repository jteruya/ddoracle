
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
            data: [{"name":"Week of 2015-12-28","drilldown":"Week of 2015-12-28","y":406651}, {"name":"Week of 2016-01-01","drilldown":"Week of 2016-01-01","y":52166}, {"name":"Week of 2016-01-04","drilldown":"Week of 2016-01-04","y":560461}, {"name":"Week of 2016-01-11","drilldown":"Week of 2016-01-11","y":744969}, {"name":"Week of 2016-01-18","drilldown":"Week of 2016-01-18","y":1322769}, {"name":"Week of 2016-01-25","drilldown":"Week of 2016-01-25","y":1368340}, {"name":"Week of 2016-02-01","drilldown":"Week of 2016-02-01","y":1285299}, {"name":"Week of 2016-02-08","drilldown":"Week of 2016-02-08","y":1099664}, {"name":"Week of 2016-02-15","drilldown":"Week of 2016-02-15","y":734028}, {"name":"Week of 2016-02-22","drilldown":"Week of 2016-02-22","y":118570}]

        }],
        drilldown: {
            // series: [{"name": "2015-12-07", "id": "2015-12-07", "data": [["Corporate External", 3.29],["Corporate Internal", 53.01],["Conference", 72.53],["_Unknown", 76.47]]},{"name": "2016-01-01", "id": "2016-01-01", "data": [["Corporate Internal", 69.73]]},{"name": "2016-01-11", "id": "2016-01-11", "data": [["_Unknown", 30.27],["Expo", 40.25],["Corporate Internal", 65.10],["Conference", 73.48],["Corporate External", 66.14]]},{"name": "2016-01-25", "id": "2016-01-25", "data": [["Expo", 57.55],["_Unknown", 80.25],["Conference", 60.32],["Corporate Internal", 69.35],["Corporate External", 77.29]]},{"name": "2016-02-01", "id": "2016-02-01", "data": [["Corporate Internal", 55.85],["Conference", 32.00],["Corporate External", 66.94],["_Unknown", 48.23],["Expo", 19.15]]},{"name": "2016-01-04", "id": "2016-01-04", "data": [["_Unknown", 33.33],["Expo", 91.95],["Corporate Internal", 52.12],["Conference", 30.12],["Corporate External", 55.63]]},{"name": "2015-12-21", "id": "2015-12-21", "data": [["Corporate Internal", 68.42]]},{"name": "2015-12-14", "id": "2015-12-14", "data": [["Corporate External", 68.87],["Corporate Internal", 62.63]]},{"name": "2015-12-28", "id": "2015-12-28", "data": [["Conference", 96.98],["Corporate Internal", 81.72]]},{"name": "2016-01-18", "id": "2016-01-18", "data": [["Expo", 8.64],["_Unknown", 37.61],["Conference", 59.03],["Corporate Internal", 55.75],["Corporate External", 71.19]]}]
            series: [{"name": "Week of 2016-01-18", "id": "Week of 2016-01-18", "data": [["Conference", 285742],["Corporate External", 99880],["Corporate Internal", 837922],["Expo", 74662],["_Unknown", 24563]]},{"name": "Week of 2016-01-11", "id": "Week of 2016-01-11", "data": [["Conference", 143399],["Corporate External", 4799],["Corporate Internal", 584812],["Expo", 822],["_Unknown", 11137]]},{"name": "Week of 2015-12-28", "id": "Week of 2015-12-28", "data": [["Conference", 402416],["Corporate External", 0],["Corporate Internal", 4235],["Expo", 0],["_Unknown", 0]]},{"name": "Week of 2016-01-01", "id": "Week of 2016-01-01", "data": [["Conference", 0],["Corporate External", 0],["Corporate Internal", 52020],["Expo", 146],["_Unknown", 0]]},{"name": "Week of 2016-02-22", "id": "Week of 2016-02-22", "data": [["Conference", 23907],["Corporate External", 39591],["Corporate Internal", 55072],["Expo", 0],["_Unknown", 0]]},{"name": "Week of 2016-02-08", "id": "Week of 2016-02-08", "data": [["Conference", 375460],["Corporate External", 225840],["Corporate Internal", 279826],["Expo", 49052],["_Unknown", 169486]]},{"name": "Week of 2016-02-01", "id": "Week of 2016-02-01", "data": [["Conference", 651098],["Corporate External", 70449],["Corporate Internal", 462568],["Expo", 69244],["_Unknown", 31940]]},{"name": "Week of 2016-02-15", "id": "Week of 2016-02-15", "data": [["Conference", 234463],["Corporate External", 142153],["Corporate Internal", 262897],["Expo", 288],["_Unknown", 94227]]},{"name": "Week of 2016-01-25", "id": "Week of 2016-01-25", "data": [["Conference", 115884],["Corporate External", 261568],["Corporate Internal", 728002],["Expo", 245192],["_Unknown", 17694]]},{"name": "Week of 2016-01-04", "id": "Week of 2016-01-04", "data": [["Conference", 159787],["Corporate External", 28300],["Corporate Internal", 354367],["Expo", 13242],["_Unknown", 4765]]}]

        }
    });
});
