
$(document).ready(function() {

iosopenloginfunnel_options = {
    chart: {
       renderTo: 'iosopenloginfunnel',
       type: 'column'
    },
    title: {
        text: 'iOS Open Login Funnel'
    },
    subtitle: {
        text: 'Source: Robin'
    },
    xAxis: {
        categories: []
    },
    yAxis: {
        min: 0,
        title: {
            text: 'Unique Device Count'
        }
    },
    tooltip: {
        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
            '<td style="padding:0"><b>{point.y:,.0f} devices</b></td></tr>',
        footerFormat: '</table>',
        shared: true,
        useHTML: true
    },
    plotOptions: {
        column: {
            pointPadding: 0.2,
            borderWidth: 0
        }
    },
    series: []
};

$.get('csv/KPI_Robin_iOSOpenLoginFunnel_transposed.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      //iosopenloginfunnel_options.series.push(series)
      dummy = 1;
    }
    else if (lineNo = 0) {

        var categorynames = new Array();
        
        categorynames.push(items[2]);
        categorynames.push(items[3]);
        categorynames.push(items[4]);
        categorynames.push(items[5]);
        categorynames.push(items[6]);
        categorynames.push(items[7]);
        categorynames.push(items[8]);
        categorynames.push(items[9]);

        chart.xAxis[0].setCategories(categorynames, true, true);
    }
    else if (lineNo > 0) {
      var items = line.split(',')
      
      console.log('Start');

      /*if (prev_name != '') {
         iosopenloginfunnel_options.series.push(series)  
       }*/

        var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]        

        series.data.push([items[1],parseInt(items[1])])
        series.data.push([items[2],parseInt(items[2])])
        series.data.push([items[3],parseInt(items[3])])
        series.data.push([items[4],parseInt(items[4])])
        series.data.push([items[5],parseInt(items[5])])
        series.data.push([items[6],parseInt(items[6])])
        series.data.push([items[7],parseInt(items[7])])
        series.data.push([items[8],parseInt(items[8])])
        series.data.push([items[9],parseInt(items[9])])        
        prev_series = series

        iosopenloginfunnel_options.series.push(series) 

        console.log(series);
    }    
  })

iosopenloginfunnel = new Highcharts.Chart(iosopenloginfunnel_options);

});


});


