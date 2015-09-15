// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

usercount_options = {
  chart: {
    renderTo: 'usercount',
    // type: 'scatter',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Active User Counts per Month'
  },
  subtitle: {
    text: 'Actual vs. Projected'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %Y', this.x) + '</b>: <br>' + this.series.name + ': ' + this.y + ' Active Users in this Month';

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
      text: 'Count of Active Users'
    }
  },
  colors: ['rgba(223, 83, 83, .8)','rgba(119, 152, 191, .8)'],
  plotOptions: {
    series: {
      groupPadding: 0.1, // Spacing between x-axis categories
      marker: {
        enabled: true,
        radius: 5 // Size of markers
      }
    }
  },
  series: []
};

$.get('csv/KPI_Robin_UserCount_pred.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      usercount_options.series.push(series)
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

        // We are starting another series (first new or next new)
        console.log('Start');

        // Push out the previous series if we are starting a new one
        if (prev_name != '') {
          usercount_options.series.push(series)  
        }

        // Initiate the series
        if (prev_name == '') {
          var series = {
          name: '',
          type: 'scatter',
          marker: { radius: 5},
          data: []
          }
        }
        else {
          var series = {
          name: '',
          type: 'line',
          marker: { radius: 1},
          data: []
          }
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

usercount = new Highcharts.Chart(usercount_options);

});

});

