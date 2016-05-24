
$(document).ready(function() {

iosloginfunnel_options = {
    chart: {
       renderTo: 'iosloginfunnel',
       type: 'bar'
    },
    title: {
        text: 'iOS Login Funnel'
    },
    subtitle: {
        text: 'Source: Robin'
    },
    xAxis: {
        categories: ['Enter Email View', 
                     'Enter Password View', 
                     'Reset Password View (Optional)', 
                     'Event Picker View', 
                     'LinkedIn Import View (Not on all Events)', 
                     'Profile Filler View', 
                     'Login Success'],
        title: {
           text: 'Login Funnel Steps'
        }
    },
    yAxis: {
        min: 0,
        title: {
            text: 'Unique Device Count'
        }
    },
    legend: {
      reversed: true
    },
    plotOptions: {
        series: {
          stacking: 'normal'
        }
    },
    series: []
};

$.get('csv/KPI_Robin_iOSLoginFunnel.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  var prev_name = ''
  var prev_series = {}

  $.each(lines, function(lineNo, line) {
    series = prev_series
    if (lineNo == linecnt) {
      console.log('End');
      //iosloginfunnel_options.series.push(series)
      dummy = 1;
    }
    else if (lineNo > 0) {
      var items = line.split(',')
      
      console.log('Start');

         var series = {
          name: '',
          data: []
        }

        series.name = items[0]
        prev_name = items[0]        

        series.data.push([items[2],parseFloat(items[2])])
        series.data.push([items[3],parseFloat(items[3])])
        series.data.push([items[4],parseFloat(items[4])])
        series.data.push([items[5],parseFloat(items[5])])
        series.data.push([items[6],parseFloat(items[6])])
        series.data.push([items[7],parseFloat(items[7])]) 
        series.data.push([items[8],parseFloat(items[8])])    
        prev_series = series

        iosloginfunnel_options.series.push(series) 

        console.log(series);

    }    
  })

iosloginfunnel = new Highcharts.Chart(iosloginfunnel_options);

});


});


