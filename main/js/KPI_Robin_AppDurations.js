// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

appdurations_options = {
  chart: {
    renderTo: 'appdurations',
    type: 'spline',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Per User, In-App Duration by week'
  },
  subtitle: {
    text: '(Median across User In-App Durations, past 8 weeks)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %e, %Y', this.x) + '</b>: <br>' + this.y + ' minutes';

    return s;
    }
  },
  legend: {
    enabled: false,
    align: 'bottom',
    align: 'center',
    layout: 'vertical'
  },
  xAxis: {
    title: {
      // text: 'Year/Week #'
    },
    type: 'datetime',
    dateTimeLabelFormats: {
      week: '%b %e, %Y'
    }
  },
  yAxis: {
    min: 0, // Minimum start at 0 on y-axis
    title: {
      text: 'Duration (minutes)'
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

$.get('csv/KPI_Robin_AppDurations.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  //console.error(linecnt)

  var series = {
        name: '',
        data: []
      }

  var columns = lines[0].split(',')
  $.each(lines, function(lineNo, line) {
    if (lineNo == linecnt) {
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')
      
      var year = parseInt(items[0].split('-')[0])
      var week = parseInt(items[0].split('-')[1])

      // Jan 1 of 'year'
      var d = new Date(year, 0, 1),
          offset = d.getTimezoneOffset();

      // ISO: week 1 is the one with the year's first Thursday 
      // so nearest Thursday: current date + 4 - current day number
      // Sunday is converted from 0 to 7
      d.setDate(d.getDate() + 4 - (d.getDay() || 7));

      // 7 days * (week - overlapping first week)
      d.setTime(d.getTime() + 7 * 24 * 60 * 60 * 1000 
          * (week + (year == d.getFullYear() ? -1 : 0 )));

      // daylight savings fix
      d.setTime(d.getTime() 
          + (d.getTimezoneOffset() - offset) * 60 * 1000);

      // back to Monday (from Thursday)
      d.setDate(d.getDate() - 3);

      series.data.push([Date.parse(d),parseFloat(items[1])])

      appdurations_options.series.push(series)
    }
  })

appdurations = new Highcharts.Chart(appdurations_options);

});

});

