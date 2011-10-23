class IngredientsKitchen < ActiveRecord::Base
  belongs_to :kitchen
  belongs_to :ingredient
  validates_presence_of :kitchen, :ingredient

  #-------------------
  def ingredients
    return ingredient.names
  end

  #################
  # Class methods
  #################
    
  #-------------------
  def self.update_list(ik_id, state, shop_list)
    ik = find(ik_id)
    if shop_list == true || shop_list == 'true'
      ik.bought = state
    else
      ik.needed = state
    end
    ik.save!
  end

end
