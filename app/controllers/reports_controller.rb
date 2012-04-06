class ReportsController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def reports
    @group_codes = Group.find(:all)
  end
  
  def leaderboard
    @leaderboard = User.find_by_sql("SELECT Users.id, Users.First, Users.Last, SUM(Points.points) AS sum_points
      FROM `users_points` , users, points
      WHERE users.id = users_points.user_id 
      and points.id = users_points.point_id
      GROUP BY Users.id
      ORDER BY sum_points DESC")  
    
  end
  
  def get_group_report
    
  end
end
