class ReportsController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  
end
