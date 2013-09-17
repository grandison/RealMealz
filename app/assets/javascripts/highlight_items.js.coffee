ShopPageManagement = window.ShopPageManagement = 
	highlight: (targetIDs) ->
		$items = $(".js-shop-container .js-shop-item")
		$items.removeClass "s-highlighted"

		$matchItems = $items.filter(->
		  isInTargetIDs = $.inArray(parseInt($(@).attr("id"), 10), targetIDs) > -1
		  true if isInTargetIDs
		)

		$matchItems.addClass "s-highlighted"

	addHighlightHandlers: ->
		# Delegate is 
		$(document).delegate ".recipe-display", "click", ->
		  $this = $(this)
		  recipeId = $this.attr("recipe-id")
		  $.post "/shop/highlight_ingredients", "recipe_id=" + recipeId


