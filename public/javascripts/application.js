// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$.ajaxSetup({
  error: function(request, status, error) {
    alert("An AJAX error occurred: " + status + "\nError: " + error + "\n" + 
    $(request.responseText).eq(4).html() + "\n" + 
    $(request.responseText).eq(5).html());
  }
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

function setup_sortable(itemSortable, addUrl, sortTag) {
  $(itemSortable).sortable({
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
        data: 'order=' + $(itemSortable).sortable("toArray", {attribute: "recipe-id"}) + "&sort_tag=" + sortTag
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
  series.data.push(	{name: 'Protein', y: parseFloat(myprotein)});
	options.series.push (series);
  return new Highcharts.Chart(options);
};

function setup_recipe_bar_graphs() {
	var charts = new Array();
	var arr = document.getElementsByClassName("recipe-bar-middle");
	for (i = 0; i < arr.length; i++) { 
		var protein = $(arr[i]).attr("protein"); //document.getElementById(arr[i]);
		var veg = $(arr[i]).attr("veg");
		var starch = $(arr[i]).attr("starch");
	  charts[i] = createGraphSmall(protein, veg, starch, arr[i],'rgb(215,147,58)');
	}
};
