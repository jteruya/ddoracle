// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

androidclosedloginfunnelmonthly_options = {
  chart: {
    renderTo: 'androidclosedloginfunnelmonthly',
    type: 'area',
    // zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Android Closed Bundle Login Funnel per Month'
  },
  subtitle: {
    text: '(for the past 6 Months)'
  },
  tooltip: {
    formatter: function () {
    /*var prevPoint = this.series.data[this.point.x - 1];*/
    /*var test = ProfileFillerView.[this.x].y*/
    if (this.series.name != 'ActivityFeed' && this.series.name != 'EnterEmail') {
       var s = '<b> Login Step: ' + this.series.name + '</b><br> <b>Month: ' + Highcharts.dateFormat('%b %Y', this.x) + '</b><br>' + Highcharts.numberFormat(this.point.count, 0, '', ',') + ' Devices <br>' + (this.y) + '% Step Drop Off <br>' + (this.point.total_drop) + '% Retention of Total Devices';  
    }
    else if (this.series.name == 'EnterEmail') {
       var s = '<b> Login Step: ' + this.series.name + '</b><br> <b>Month: ' + Highcharts.dateFormat('%b %Y', this.x) + '</b><br>' + Highcharts.numberFormat(this.point.count, 0, '', ',') + ' Devices <br>' + (this.y) + '% Step Drop Off';  
    }
    else {
       var s = '<b> Login Step: ' + this.series.name + '</b><br> <b>Month: ' + Highcharts.dateFormat('%b %Y', this.x) + '</b><br>' + Highcharts.numberFormat(this.point.count, 0, '', ',') + ' Devices <br>' + (this.point.total_drop) + '% Retention of Total Devices';
    }
    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'center',
    verticalAlign: 'bottom',
    // backgroundColor: '#FCFFC5',
    // borderColor: '#000000',
    borderWidth: 1,
    layout: 'horizontal'
  },
  xAxis: {
    title: {
      text: 'Month'
    },
    type: 'datetime',
    dateTimeLabelFormats: {
      month: '%b %Y',
    }
  },
  yAxis: {
    min: 0, // Minimum start at 0 on y-axis
    max: 100,
    title: {
      text: '% Retention of Total Devices'
    }
  },
  plotOptions: {
    area: {
                stacking: 'percent',
                lineColor: '#ffffff',
                lineWidth: 1,
                marker: {
                    lineWidth: 1,
                    lineColor: '#ffffff'
                }
            }

    // series: {
    //   groupPadding: 0.1, // Spacing between x-axis categories
    //   marker: {
    //     enabled: true,
    //     radius: 2 // Size of markers
      // }
    // }
  },
  series: []
};

$.get('csv/KPI_Robin_AndroidClosedLoginFunnelMonthly.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      androidclosedloginfunnelmonthly_options.series.push(series)
      dummy = 1;
    }
        
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');

        var year = parseInt(items[2].split('-')[0])
        var month = parseInt(items[2].split('-')[1]) - 1
        //var day = parseInt(items[2].split('-')[2])
        
        series.data.push({x:Date.UTC(year,month,1),y:parseFloat(items[3]),total_drop:parseFloat(items[4]),count:parseFloat(items[5])})

        console.log(series);

      }
      else {
        console.log('Start');

        if (prev_name != '') {
          androidclosedloginfunnelmonthly_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]

        var year = parseInt(items[2].split('-')[0])
        var month = parseInt(items[2].split('-')[1]) - 1
        //var day = parseInt(items[2].split('-')[2])

        series.data.push({x:Date.UTC(year,month,1),y:parseFloat(items[3]),total_drop:parseFloat(items[4]),count:parseFloat(items[5])})
        prev_series = series

        console.log(series);
          
      }
    }
  })

androidclosedloginfunnelmonthly = new Highcharts.Chart(androidclosedloginfunnelmonthly_options);

});

});

