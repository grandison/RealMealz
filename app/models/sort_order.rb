class SortOrder < ActiveRecord::Base
  belongs_to :kitchen
  
  ###############
  # Class methods
  ###############
  
  #-------------------------------------------
  def self.update_order(kitchen, tag, new_order)
    sort_order = find_or_create_by_kitchen_id_and_tag(:kitchen_id => kitchen.id, :tag => tag)
    
    # Can contain prefix characters, so strip all but numbers
    num_order = new_order.split(',').map {|s| s.gsub(/[^0-9]/, '')}.join(',')
    sort_order.update_attributes!(:order => num_order)
  end

  #-------------------------------------------
   def self.list_sort(kitchen_id, tag, list)
     sort_order = find_by_kitchen_id_and_tag(kitchen_id, tag)
     return list if sort_order.blank? || sort_order.order.blank?
     
     sort_string = sort_order.order + ','  # add ending comma to find last item
     list.sort do |item1, item2| 
       index1 = index_nil_last(sort_string,item1.id)
       index2 = index_nil_last(sort_string,item2.id)
       index1 <=> index2
     end
   end

   #######################
   private
   #######################

   #-------------------------------------------
   def self.index_nil_last(sort_string, value)
     ret_index = sort_string.index("#{value},")  # search for comma too so substrings not accidently found
     ret_index = 999999 if ret_index.nil?
     ret_index
   end


  
end
