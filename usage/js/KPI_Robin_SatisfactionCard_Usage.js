// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

satisfactioncardusage_options = {
  chart: {
    renderTo: 'satisfactioncardusage',
    type: 'spline',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Satisfaction Card Usage - % by Month'
  },
  subtitle: {
    text: '(for the past 13 months since feature launched)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %Y', this.x) + '</b>: <br>' + this.y + ' ' + this.series.name;

    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'center',
    verticalAlign: 'bottom',
    // backgroundColor: '#FCFFC5',
    // borderColor: '#000000',
    // borderWidth: 1,
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
      text: '% of Events'
    }
  },
  colors: [ 'rgba(241, 103, 69, 1)',
            'rgba(255, 154, 3, 0.5)',
            'rgba(7, 181, 30, 0.5)'
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

$.get('csv/KPI_Robin_SatisfactionCard_Usage.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      satisfactioncardusage_options.series.push(series)
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
          satisfactioncardusage_options.series.push(series)  
        }

        var series = {
          name: '',
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

satisfactioncardusage = new Highcharts.Chart(satisfactioncardusage_options);

});

});

