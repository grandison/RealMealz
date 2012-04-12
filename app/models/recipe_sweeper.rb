class RecipeSweeper < ActionController::Caching::Sweeper
  observe Recipe 
 
  def after_create(recipe)
    expire_cache_for(recipe)
  end
 
  def after_update(recipe)
    expire_cache_for(recipe)
  end
 
  def after_destroy(recipe)
    expire_cache_for(recipe)
  end
 
  #######
  private
  #######
  
  def expire_cache_for(recipe)
    expire_fragment('recipes')
  end
end