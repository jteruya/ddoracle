// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

deviceosdistributioniphone_options = {
  chart: {
    renderTo: 'deviceosdistributioniphone',
    type: 'area',
    // zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'User Device OS (iPhone) Distribution - by Month'
  },
  subtitle: {
    text: '(for the past 3 months)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + this.series.name + ' (' + Highcharts.dateFormat('%b %Y', this.x) + ')</b>: <br>' + this.y + ' % of Devices';

    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'right',
    verticalAlign: 'middle',
    // backgroundColor: '#FCFFC5',
    // borderColor: '#000000',
    borderWidth: 1,
    layout: 'vertical'
  },
  xAxis: {
    title: {
      text: ''
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
      text: '% of Devices'
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

$.get('csv/KPI_Robin_DeviceOSDistribution_iPhone.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      deviceosdistributioniphone_options.series.push(series)
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1
        
        series.data.push([Date.UTC(year,month,1),parseFloat(items[2])])

        console.log(series);

      }
      else {

        console.log('Start');

        if (prev_name != '') {
          deviceosdistributioniphone_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1

        series.data.push([Date.UTC(year,month,1),parseFloat(items[2])])
        prev_series = series

        console.log(series);
          
      }
    }
  })

deviceosdistributioniphone = new Highcharts.Chart(deviceosdistributioniphone_options);

});

});

