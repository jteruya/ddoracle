// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

adoption_options = {
  chart: {
    renderTo: 'adoption',
    type: 'spline',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Adoption % for Events starting in each Month'
  },
  subtitle: {
    text: '(for the past 13 months)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %Y', this.x) + '</b> (' + this.series.name + '): <br>' + this.y + '%';

    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'bottom',
    align: 'center',
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
    max: 100, // Maximum at 100 on y-axis
    title: {
      text: ''
    }
  },
  colors: [ 'rgba(241, 103, 69, 1)',
            'rgba(255, 154, 3, 0.5)',
            'rgba(7, 181, 30, 0.5)',
            'rgba(76, 195, 217, 0.5)',
            'rgba(147, 100, 141, 0.5)',
            'rgba(64, 64, 64, 0.5)',
            'rgba(75, 0, 130,0.5)',
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

$.get('csv/KPI_Robin_AdoptionReport.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      adoption_options.series.push(series)
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
          adoption_options.series.push(series)  
        }

        var series = {
          name: '',
          lineWidth: 2.5,
          data: []
        }

        if (prev_name == '') {
          series.lineWidth = 10
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

adoption = new Highcharts.Chart(adoption_options);

});

});

