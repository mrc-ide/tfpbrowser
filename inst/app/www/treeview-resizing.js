$(document).on("shiny:connected", function(e) {
    var w = window.innerWidth;
    var h = window.innerHeight;
    var d =  document.getElementById("ppitest").offsetWidth;
    var obj = {width: w, height: h, dpi: d};
    Shiny.onInputChange("pltChange", obj);
});
$(window).resize(function(e) {
    var w = $(this).width();
    var h = $(this).height();
    var d =  document.getElementById("ppitest").offsetWidth;
    var obj = {width: w, height: h, dpi: d};
    Shiny.onInputChange("pltChange", obj);
});
