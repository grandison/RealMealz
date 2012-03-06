// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Provide a universal ajax error handler
$.ajaxSetup({
  error: function(request, status, error) {
    alert("An AJAX error occurred: " + status + "\nError: " + error + "\n" + 
    $(request.responseText).eq(4).html() + "\n" + 
    $(request.responseText).eq(5).html());
  }
});

// Log all jQuery AJAX requests to Google Analytics
$(document).ajaxSend(function(event, xhr, settings){ 
  if (typeof _gaq !== "undefined" && _gaq !== null) {
    _gaq.push(['_trackPageview', settings.url]);
  }
});

// Process flash messages on ajax calls 
$(document).ajaxComplete(function(event, request){
  var flash = $.parseJSON(request.getResponseHeader('X-Flash-Messages'));
  if(!flash || $.isEmptyObject(flash)) { return; };
  var msg = '';
  if(flash.error) { msg += "<div class='flash' id='flash-error'>" + flash.error + "</div>" };
  if(flash.warning) { msg += "<div class='flash' id='flash-warning'>" + flash.warning + "</div>" };
  if(flash.notice) { msg += "<div class='flash' id='flash-notice'>" + flash.notice + "</div>" };
  $('#flash-div').html(msg); 
  $('#points').html(flash.points);
});  

function setup_draggable(itemDraggable, connectTo) {
  $(itemDraggable).draggable({
    appendTo: 'body',
    helper: 'clone',
    cursor: 'crosshair',
    revert: 'invalid',
    connectToSortable: connectTo
  });
};  

function setup_sortable(sortableSel, sortTag, addUrl) {
  $(sortableSel).sortable({
    placeholder: 'ui-state-highlight',
    forcePlaceholderSize: true,
    items: 'li',
    revert: true,
    opacity: 0.5,
    cursor: 'move',
    receive: function(event, ui) {
      $.ajax({
        type:"post",
        url: addUrl,
        data: 'recipe_id=' + ui.item.attr("recipe-id")
      });
    },
    update: function(event, ui) {
      $.ajax({
        type:"post",
        url: "/sort_order/update_order", 
        data: 'order=' + $(sortableSel).sortable("toArray", {attribute: "recipe-id"}) + "&sort_tag=" + sortTag
      });
    }
  });
};

function setup_trash(itemTrash, deleteUrl) {
  $(itemTrash).droppable({
    tolerance: 'pointer',
    hoverClass: 'ui-state-highlight',
    drop: function(event, ui) { 
      $.ajax({
        type:"post",
        url: deleteUrl,
        data: 'recipe_id=' + ui.draggable.attr("recipe-id")
      });
      ui.draggable.fadeTo("slow", 0.00, function(){
        $(this).slideUp("slow", function() {
           $(this).remove();
         }); 
      });
    }
  });
};

function createGraphSmall(myprotein, myveg, mystarch, renderTo, backgroundColor){
  var options = {
    	chart: {
			    renderTo: renderTo,
	    		type: 'pie',
	    		animation: false,
	    		backgroundColor: backgroundColor
	     },
	     title: {
	        text: null,	
	        floating: true
	     },
	     tooltip: {
	     	enabled: false,
			 },
			 legend: {
	        enabled: false
	     },
	     series: []
	  };
  var series = {
  	data: []
  };
  series.data.push( {name: 'Veg/Fruits', y: parseFloat(myveg)});
  series.data.push( {name: 'Grains', y: parseFloat(mystarch)});    						
  series.data.push(	{name: 'Proteins', y: parseFloat(myprotein)});
	options.series.push (series);
  return new Highcharts.Chart(options);
};

function createGraph(myprotein, myveg, mystarch, renderTo, legend){
	if (legend == true) {
		var options = {
     chart: { renderTo: renderTo, type: 'pie', backgroundColor: 'none' },
     title: { text: null,	floating: true },
     tooltip: {
			formatter: function() {
				return '<b>'+ this.point.name +'</b>: '+ parseInt(this.percentage) +' %';
			}
		 },
		 legend: { 
      itemStyle: { color: '#7A530C' },
      itemHoverStyle: { color: '#FFF' },
      itemHiddenStyle: { color: '#444' }
		 },
     series: []
   };
	}
  else {
    var options = {
    	chart: { renderTo: renderTo, type: 'pie', backgroundColor: 'none' },
	     title: { text: null,	floating: true },
	     tooltip: {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ parseInt(this.percentage) +' %';
				}
			 },
			 legend: { enabled: false },
	     series: []
	  };
	};
  var series = { data: [] };
  series.data.push( {name: 'Veg/Fruits', y: parseFloat(myveg)});
  series.data.push( {name: 'Grains', y: parseFloat(mystarch)});    						
  series.data.push(	{
						name: 'Protein',    
						y: parseFloat(myprotein),
						sliced: true,
						selected: true
					});
	options.series.push (series);
  return new Highcharts.Chart(options);
};

function li_item_remove(selector, fadeSpeed, scrollbar) {
  if (typeof(fadeSpeed) == 'undefined') { fadeSpeed = "fast"};
  $("li" + selector).fadeTo(fadeSpeed, 0.00, function(){
    $(this).slideUp("fast", function() {
      $(this).remove();
      if (typeof(scrollbar) != 'undefined') {
        $(scrollbar).tinyscrollbar_update('relative');
      };
   });
 });
}

/*** Resize scroll ***/
function resize_scroll_with_window(sel) {
  $(window).resize(function() {  
    $(sel + ' .viewport').height(full_scroll_height(sel));
    $(sel).tinyscrollbar_update('relative');
  });
};

function full_scroll_height(sel) {
  return $(window).height() - $(sel).offset().top - 10; //Scroll height - 10 padding
};

/* "sel" is the div to scroll 
 * if the height of this is set, the scroll will also be that height
 * but if the height is 0, then scroll will be the full window height
 * Also, check if the scroll already setup and if so, just update
 */
function setup_scroll(sel) {
  if ($(sel).find(".overview").length) {
    $(sel).tinyscrollbar_update(); 
  } else {
    $(sel).wrapInner('<div class="overview" />').wrapInner('<div class="viewport" />');
    $(sel).prepend($('<div class="scrollbar"><div class="track"><div class="thumb"> <div class="end"></div></div></div></div>')); 

    var height = $(sel).height();
    if (height == 0) { 
      height = full_scroll_height(sel);
      resize_scroll_with_window(sel);
    }
    var width = $(sel).width();
    if (width == 0) { width = $(sel).parent().width() };
    var $viewport = $(sel).find('.viewport');

    if ($viewport.width() == 0) {
      $viewport.width(width - 20);
    };
    if ($viewport.height() == 0) {
      $viewport.height(height);
    };
    $(sel).tinyscrollbar();
  }
};

function setup_background_image(sel) {
  /* When users click on picture, change the background image */
  $(sel).click(function() {
    $('body').css('background-image', 'url(' + $(this).attr('recipe-pic') + ')'); 
  });

  /* start off with background of first, if one */
  var $firstRecipe = $(sel);
  if ($firstRecipe != 'undefined') {
    $firstRecipe.first().click();
  };
};

$(function() {
  if (!($.cookie('ie-warning-shown') == 'true')) {
    if ($.browser.msie  && parseInt($.browser.version, 10) <= 8) {
      alert('RealMealz is currently supporting FireFox and Chrome browsers only.  We have noticed that you are using Internet Explorer, which means some of the site will not work as intended.');
      $.cookie('ie-warning-shown', 'true'); 
    }
  }
});

