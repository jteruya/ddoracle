// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

inappleadtappingusers_options = {
  chart: {
    renderTo: 'inappleadtappingusers',
    type: 'spline',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Attendees tapping App-By-DoubleDutch'
  },
  subtitle: {
    text: '(for the past 390 days)'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %Y', this.x) + '</b>: <br>' + this.y + ' attendees tapped App-By-DoubleDutch';

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
      text: 'Bookmarks per User'
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

$.get('csv/KPI_Robin_InAppLeadTappingUsers_transposed.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;

  var columns = lines[0].split(',')
  $.each(lines, function(lineNo, line) {
    if (lineNo == linecnt) {
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')
      var series = {
        name: '',
        data: []
      }
      series.name = items[0]
      $.each(items, function(itemNo, item) {
        if (itemNo > 0) {
          var year = parseInt(columns[itemNo].split('-')[0])
          var month = parseInt(columns[itemNo].split('-')[1]) - 1 // offset months in JS
          var value = parseFloat(items[itemNo]) 
          series.data.push([Date.UTC(year,month,1),value])

        }
      })
      inappleadtappingusers_options.series.push(series)
    }
  })

inappleadtappingusers = new Highcharts.Chart(inappleadtappingusers_options);

});

});

