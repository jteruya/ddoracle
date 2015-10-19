// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

metricspermonth_options = {
  chart: {
    renderTo: 'metricspermonth',
    type: 'column',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Metric Datapoints per Month'
  },
  subtitle: {
    text: '(for the past 4 months)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %Y', this.x) + '</b>: <br>' + Highcharts.numberFormat(this.y, 0, '', ',') + ' ' + this.series.name + ' collected.';

    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'center',
    verticalAlign: 'bottom',
    // backgroundColor: '#FCFFC5',
    borderColor: '#000000',
    borderWidth: 1,
    layout: 'horizontal'
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
    title: {
      text: '# of Events'
    }
  },
  colors: [ 'rgba(241, 103, 69, 1)',
            'rgba(255, 198, 93, 1)',
            'rgba(123, 200, 164, 1)',
            'rgba(76, 195, 217, 1)',
            'rgba(147, 100, 141, 1)',
            'rgba(64, 64, 64, 1)'
          ],
  plotOptions: {
    series: {
      groupPadding: 0.1, // Spacing between x-axis categories
      marker: {
        enabled: true,
        radius: 2 // Size of markers
      }
    }
  },
  series: []
};

$.get('csv/KPI_Robin_MetricsPerMonth.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      metricspermonth_options.series.push(series)
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1 // offset months in JS
        
        series.data.push([Date.UTC(year,month,1),parseFloat(items[2])])

        console.log(series);

      }
      else {

        console.log('Start');

        if (prev_name != '') {
          metricspermonth_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1 // offset months in JS

        series.data.push([Date.UTC(year,month,1),parseFloat(items[2])])
        prev_series = series

        console.log(series);
          
      }
    }
  })

metricspermonth = new Highcharts.Chart(metricspermonth_options);

});

});

