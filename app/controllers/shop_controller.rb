class ShopController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  autocomplete :ingredient, :name, :display_value => :display_name
  
  def shop_list
    @item_list = current_user.kitchen.get_sorted_shopping_items
    @action_shop = true
    render :shop
  end
  
  def pantry_list
    @item_list = current_user.kitchen.get_sorted_pantry_items 
    @action_shop = false
    render :shop
  end

  def add_item
    current_user.kitchen.add_new_pantry_item(params[:new_item_name])
    redirect_to "/shop"
  end
  
  def remove_item
    ik = IngredientsKitchen.find_by_id(params[:remove_item])
    ik.destroy!
    redirect_to "/shop"
  end
  
  def fetch_item
    ik = IngredientsKitchen.find_by_id(params[:id])
    @name = ik.ingredient.name
    @note = ik.note
  end
  
  def update
    IngredientsKitchen.update_list(params[:id], params[:value], params[:shop])
    render :nothing => true
  end

  def delete
    IngredientsKitchen.delete(params[:id])
    render :nothing => true
  end
  
  def update_item
    ik = IngredientsKitchen.find_by_id(params[:item][:id])
    ##TODO Disable updating of name for now. Only let them change name
    # if item is special in their kitchen. Otherwise, need to see if name is already an ingredient and
    # point to that. If not, then copy as special
    params[:item].delete(:name)
    ik.update_attributes!(params[:item])
    redirect_to "/shop"
  end
  
  def update_order
    if params[:shop] == true || params[:shop] == 'true'
      which_list = :shop_order
    else
      which_list = :pantry_order
    end
    current_user.kitchen.update_order(params[:order], which_list)
    render :nothing => true
  end
  
  def done_shopping
    current_user.kitchen.done_shopping
    redirect_to "/shop"
  end
end
