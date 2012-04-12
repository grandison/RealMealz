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

function createGraph(myprotein, myveg, mystarch, renderTo, legend){
  if (legend == true) {
	  var legendHash = { 
      itemStyle: { color: '#7A530C' },
      itemHoverStyle: { color: '#FFF' },
      itemHiddenStyle: { color: '#444' }
    }
  } else {
    var legendHash = { enabled: false }
  }
   
  var options = {
    chart: { renderTo: renderTo, type: 'pie', backgroundColor: 'none', inverted: true },
    title: { text: null },
    tooltip: {
      backgroundColor: "rgba(255,255,255,0)",
      borderWidth: 0,
      shadow: false,
      useHTML: true,  
      formatter: function() {
    	  return '<div class="highcharts-tooltip"><b>'+ this.point.name +'</b>: '+ parseInt(this.percentage) +' %</div>';
    	}
    },
    legend: legendHash,
    credits: { enabled: false },
    plotOptions: { clip: false },
    series: []
  };
  var series = { data: [] };
  series.data.push( { name: 'Veg/Fruits', y: parseFloat(myveg)});
  series.data.push( { name: 'Grains', y: parseFloat(mystarch)});    						
  series.data.push(	{ name: 'Protein', y: parseFloat(myprotein), sliced: true, selected: true });
	options.series.push (series);
  return new Highcharts.Chart(options);
};

function li_item_remove(selector, fadeSpeed, scrollbar) {
  if (typeof(fadeSpeed) == 'undefined') { fadeSpeed = "fast"};
  $("li" + selector).fadeTo(fadeSpeed, 0.00, function(){
    $(this).slideUp("fast", function() {
      $(this).remove();
      if (typeof(scrollbar) != 'undefined') {
        update_scroll(scrollbar);
      };
   });
 });
}

/*** Resize scroll ***/
function resize_scroll_with_window(sel) {
  $(window).resize(function() {  
    $(sel).height(full_scroll_height(sel));
    $(sel).width($(sel).width() - 2);
    update_scroll(sel);
  });
};

function full_scroll_height(sel) {
  return $(window).height() - $(sel).offset().top - 10; //Scroll height - 10 padding
};

function update_scroll(sel) {
  $(sel).data('jsp').reinitialise();
}

function scroll_top(sel) {
  $(sel).data('jsp').scrollTo(0,0);
}

function scroll_pane(sel) {
  return $(sel).data('jsp').getContentPane();
}

/* "sel" is the div to scroll 
 * if the height of this is set, the scroll will also be that height
 * but if the height is 0, then scroll will be the full window height
 * Also, check if the scroll already setup and if so, just update
 */
function setup_scroll(sel, useHeight) {
  if (!useHeight) { 
    $(sel).height(full_scroll_height(sel));
    resize_scroll_with_window(sel); 
  };
  $(sel).jScrollPane({
    animateScroll : true,
    animateDuration : 1000,
    animateEase : 'swing',
    verticalGutter : 0,
    hideFocus : true
  });
};

function setup_background_image(sel) {
  /* When users click on picture, change the background image and url */
  $(sel).click(function() {
    window.history.replaceState('Object', 'Title', '/discover/' +  $(this).attr('recipe-id') + '/' +  $(this).attr('recipe-name'));
    $('body').css('background-image', 'url(' + $(this).attr('recipe-pic') + ')'); 
  });

  /* start off with background of first, if one */
  var $firstRecipe = $(sel);
  if ($firstRecipe != 'undefined') {
    $firstRecipe.first().click();
  };
};

/** Give warning once, if IE version is <= 8 **/
$(function() {
  if (!($.cookie('ie-warning-shown') == 'true')) {
    if ($.browser.msie  && parseInt($.browser.version, 10) <= 8) {
      alert('RealMealz is currently supporting FireFox and Chrome browsers only.  We have noticed that you are using Internet Explorer, which means some of the site will not work as intended.');
      $.cookie('ie-warning-shown', 'true'); 
    }
  }
});

/** Make sure #main is as at least high as the window **/
function set_main_height() {
  var fullHeight = full_scroll_height('#main') + 10;
  $('#main').css('height',''); // Reset to get true height
  if ($('#main').height() < fullHeight) {
    $('#main').height(fullHeight);
  } else {
    $('#main').height('');
  }
};

$(window).resize(function() {  
  set_main_height();
});

