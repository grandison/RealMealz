class ShopCell < Cell::Rails

  def shop_list(current_user, mobile_request)
    @item_list = current_user.kitchen.get_sorted_shopping_items
    render :locals => {:action_shop => true, :item_list => @item_list,  
      :mobile_request => mobile_request}
  end

  def pick_list(current_user, mobile_request)
    @item_list = current_user.kitchen.get_sorted_pantry_items 
    render :view => :shop_list, :locals => {:action_shop => false, :item_list => @item_list,  
      :mobile_request => mobile_request}
  end
end
