// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

iosloginfunneleventpickerweekly_options = {
  chart: {
    renderTo: 'iosloginfunneleventpickerweekly',
    type: 'column',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'iOS Login Funnel Device Per Week'
  },
  subtitle: {
    text: '(Event Picker: Step 3)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>Week of ' + Highcharts.dateFormat('%b %e %Y', this.x) + '</b>: <br>' + this.y + ' ' + this.series.name + ' Devices';

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
      month: '%b %e %Y',
    }
  },
  yAxis: {
    min: 0, // Minimum start at 0 on y-axis
    title: {
      text: '# of Devices'
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

$.get('csv/KPI_Robin_iOSLoginFunnelWeekly.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      iosloginfunneleventpickerweekly_options.series.push(series)
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')

      if (items[0] == prev_name) {
        console.log('Continue');

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1 // offset months in JS
        var day = parseInt(items[1].split('-')[2])
        
        /*series.data.push({Date.UTC(year,month,day):parseFloat(items[5]),Previous:parseFloat(items[4])})*/
        series.data.push([Date.UTC(year,month,day),parseFloat(items[5])])

        console.log(series);

      }
      else {

        console.log('Start');

        if (prev_name != '') {
          iosloginfunneleventpickerweekly_options.series.push(series)  
        }

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]

        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1 // offset months in JS
        var day = parseInt(items[1].split('-')[2])

        series.data.push([Date.UTC(year,month,day),parseFloat(items[5])])
        prev_series = series

        console.log(series);
          
      }
    }
  })

iosloginfunneleventpickerweekly = new Highcharts.Chart(iosloginfunneleventpickerweekly_options);

});

});

