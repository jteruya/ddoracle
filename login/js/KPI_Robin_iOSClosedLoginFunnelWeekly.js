// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

iosclosedloginfunnelweekly_options = {
  chart: {
    renderTo: 'iosclosedloginfunnelweekly',
    type: 'area',
    // zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'iOS Closed Bundle Login Funnel per Week'
  },
  subtitle: {
    text: '(for the past 10 weeks)'
  },
  tooltip: {
    formatter: function () {
    /*var prevPoint = this.series.data[this.point.x - 1];*/
    /*var test = ProfileFillerView.[this.x].y*/
    var s = '<b>' + this.series.name + ' (Week of ' + Highcharts.dateFormat('%b %e %Y', this.x) + ')</b>: <br>' + this.y+ ' % of Devices';

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
      text: 'Week Of'
    },
    type: 'datetime',
    dateTimeLabelFormats: {
      month: '%b %e %Y',
    }
  },
  yAxis: {
    min: 20, // Minimum start at 0 on y-axis
    max: 100,
    title: {
      text: '% Retention of Devices from Previous Login Step'
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

$.get('csv/KPI_Robin_iOSClosedLoginFunnelWeekly.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      iosclosedloginfunnelweekly_options.series.push(series)
      dummy = 1;
    }
        
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');

        var year = parseInt(items[2].split('-')[0])
        var month = parseInt(items[2].split('-')[1]) - 1
        var day = parseInt(items[2].split('-')[2])
        
        series.data.push([Date.UTC(year,month,day),parseFloat(items[3])])

        console.log(series);

      }
      else {
        console.log('Start');

        if (prev_name != '') {
          iosclosedloginfunnelweekly_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]

        var year = parseInt(items[2].split('-')[0])
        var month = parseInt(items[2].split('-')[1]) - 1
        var day = parseInt(items[2].split('-')[2])

        series.data.push([Date.UTC(year,month,day),parseFloat(items[3])])
        prev_series = series

        console.log(series);
          
      }
    }
  })

iosclosedloginfunnelweekly = new Highcharts.Chart(iosclosedloginfunnelweekly_options);

});

});

