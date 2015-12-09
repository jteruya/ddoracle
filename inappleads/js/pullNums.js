function getForms(){
    var n = 0;

    $.get('csv/KPI_Robin_InAppLeads_WebForm_Count.csv', function(data) {
      var lines = data.split('\n')
      var linecnt = data.split('\n').length - 1;

      $.each(lines, function(lineNo, line) {
        if (lineNo == 1) {
            console.log(line)
            n = parseInt(line)
            console.log(n)
            document.getElementById("#forms").innerHTML = n + ' taps on App-By-DoubleDutch tied to completed web forms.';
          } 
      })
    })
}

function getFormsTotal(){
    var n = 0;

    $.get('csv/KPI_Robin_InAppLeads_MarketoLeadsTotal_Count.csv', function(data) {
      var lines = data.split('\n')
      var linecnt = data.split('\n').length - 1;

      $.each(lines, function(lineNo, line) {
        if (lineNo == 1) {
            console.log(line)
            n = parseInt(line)
            console.log(n)
            document.getElementById("#formsTotal").innerHTML = n + ' total completed web forms to date.';
          } 
      })
    })
}

function getOpps(){
    var n = 0;

    $.get('csv/KPI_Robin_InAppLeads_Opportunities_Count.csv', function(data) {
      var lines = data.split('\n')
      var linecnt = data.split('\n').length - 1;

      $.each(lines, function(lineNo, line) {
        if (lineNo == 1) {
            console.log(line)
            n = parseInt(line)
            console.log(n)
            document.getElementById("#opps").innerHTML = n + ' opportunities tied to App-By-DoubleDutch.';
          } 
      })
    })
}

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}
addLoadEvent(getForms);
addLoadEvent(getFormsTotal);
addLoadEvent(getOpps);
