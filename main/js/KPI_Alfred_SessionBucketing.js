// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

sessionbucketing_options = {
  chart: {
    renderTo: 'sessionbucketing',
    type: 'spline',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Normalized Session Bucketing per Month'
  },
  subtitle: {
    text: 'Better Performance indicated by: (1) Longer Tail and (2) Movement Up and to the Right'
  },
  tooltip: {
    formatter: function () {
    var s = this.series.name + ' - <b>' + this.x + ' sessions </b>: <br>' + this.y + '% of users (normalized)';

    return s;
    }
  },
  legend: {
    enabled: true,
    align: 'right',
    verticalAlign: 'middle',
    backgroundColor: '#FCFFC5',
    borderColor: '#000000',
    borderWidth: 1,
    layout: 'vertical'
  },
  xAxis: {
    title: {
      text: 'Number of Sessions'
    }
    // type: 'datetime',
    // dateTimeLabelFormats: {
    //   month: '%b %Y',
    // }
  },
  yAxis: {
    min: 0, // Minimum start at 0 on y-axis
    title: {
      text: 'Number of Attendees'
    }
  },
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

$.get('csv/KPI_Alfred_SessionBucketing.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;

  var columns = lines[0].split(',')
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      sessionbucketing_options.series.push(series)
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');
        
        series.data.push([parseInt(items[1]),parseFloat(items[2])])

        console.log(series);

      }
      else {

        console.log('Start');

        if (prev_name != '') {
          sessionbucketing_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]
        series.data.push([parseInt(items[1]),parseFloat(items[2])])
        prev_series = series

        console.log(series);
          
      }
    }
  })
console.log(sessionbucketing_options);

sessionbucketing = new Highcharts.Chart(sessionbucketing_options);

});

});

