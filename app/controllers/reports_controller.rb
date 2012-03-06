class ReportsController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def report
    @group_codes = Groups.find(:all)
  end
  
  def get_group_report
    
  end
end
