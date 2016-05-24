
$(document).ready(function() {

iosclosedloginfunnel_options = {
    chart: {
       renderTo: 'iosclosedloginfunnel',
       type: 'column'
    },
    title: {
        text: 'iOS Closed Login Funnel'
    },
    subtitle: {
        text: 'Source: Robin'
    },
    xAxis: {
        categories: ['Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep'],
        crosshair: true
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
            borderWidth: 1
        }
    },
    series: []
};

$.get('csv/KPI_Robin_iOSClosedLoginFunnel_transposed.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      //iosclosedloginfunnel_options.series.push(series)
      dummy = 1;
    }
    /*else if (lineNo = 0) {
        var year = parseInt(items[1].split('-')[0])
        var month = parseInt(items[1].split('-')[1]) - 1 // offset months in JS
        var day = parseInt(items[1].split('-')[2])

        iosopenloginfunnel_options.xAxis.categories.push(Date.UTC(year,month,day),parseFloat(items[2])])
        //iosopenloginfunnel_options.xAxis.categories.push(items[2])
        //iosopenloginfunnel_options.xAxis.categories.push(items[3])
        //iosopenloginfunnel_options.xAxis.categories.push(items[4])
        //iosopenloginfunnel_options.xAxis.categories.push(items[5])
        //iosopenloginfunnel_options.xAxis.categories.push(items[6])
        //iosopenloginfunnel_options.xAxis.categories.push(items[7])
        //iosopenloginfunnel_options.xAxis.categories.push(items[8])
        //iosopenloginfunnel_options.xAxis.categories.push(items[9])
    }*/
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

        series.data.push([items[1],parseFloat(items[1])])
        series.data.push([items[2],parseFloat(items[2])])
        series.data.push([items[3],parseFloat(items[3])])
        series.data.push([items[4],parseFloat(items[4])])
        series.data.push([items[5],parseFloat(items[5])])
        series.data.push([items[6],parseFloat(items[6])])
        series.data.push([items[7],parseFloat(items[7])])
        series.data.push([items[8],parseFloat(items[8])])
        series.data.push([items[9],parseFloat(items[9])])        
        prev_series = series

        iosclosedloginfunnel_options.series.push(series) 

        console.log(series);
    }    
  })

iosclosedloginfunnel = new Highcharts.Chart(iosclosedloginfunnel_options);

});


});


