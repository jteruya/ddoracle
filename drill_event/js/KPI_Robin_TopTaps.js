// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

toptaps_options = {
  chart: {
    renderTo: 'toptaps',
    type: 'bar',
    zoomType: 'x',
    height: 500,
    // width: 1000,
    borderWidth: 1
  },
  title: {
    text: 'Actions - Tap Breakdown'
  },
  subtitle: {
    text: '(Top 25 Actions performed)'
  },
  tooltip: {
    formatter: function () {
    var s = Highcharts.numberFormat(this.y, 0, '', ',') + ' Taps';

    return s;
    }
  },
  legend: {
    enabled: false,
    align: 'center',
    verticalAlign: 'bottom',
    backgroundColor: '#FCFFC5',
    borderColor: '#000000',
    borderWidth: 1,
    layout: 'horizontal'
  },
  xAxis: {
    type: 'category',
    tickInterval: 1,
        labels: {
            enabled: true
            // formatter: function() { return toptaps.name;},
        }
  },
  yAxis: {
    min: 0, // Minimum start at 0 on y-axis
    title: {
      text: ''
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

$.get('csv/KPI_Robin_TopTaps.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;

  var series = {
    name: 'Tap Breakdown',
    data: []
  }

  var columns = lines[0].split(',')
  $.each(lines, function(lineNo, line) {
    if (lineNo == linecnt) {
      dummy = 1;
    }    
    else if (lineNo > 0 && lineNo <= 25) {
      var items = line.split(',')
      
      var Tapped = items[0]
      var Tapped_Cnt = parseFloat(items[1])
      var Tapped_Pct = parseFloat(items[2])

      console.log([Tapped, Tapped_Cnt, Tapped_Pct])
      series.data.push([Tapped,Tapped_Cnt])

    }
  })

  toptaps_options.series.push(series)

toptaps = new Highcharts.Chart(toptaps_options);
console.log(toptaps)
});

});
