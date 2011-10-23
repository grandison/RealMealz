class SortOrderController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def update_order
    SortOrder.update_order(current_user.kitchen, params[:sort_tag], params[:order])
    render :nothing => true
  end
  
end