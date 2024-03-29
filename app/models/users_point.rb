class UsersPoint < ActiveRecord::Base
  belongs_to :user
  belongs_to :point
  
  def self.points_by_group
    UsersPoint.order(:user_id, :date_added).includes(:user, :point).map do |up| 
      if up.user.nil? || up.point.nil?
        up.delete
      else
        {:name => up.user.name,  :action => up.point.name,  :date => up.date_added}
      end
    end
  end
  

end
