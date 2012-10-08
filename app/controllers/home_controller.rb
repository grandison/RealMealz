class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user, :except => [:index, :welcome, :about_us, :privacy_policy, :terms_of_service, :downloads, 
  :faq, :sponsor, :ping, :sign_up, :create_user, :recipes]
  before_filter :background_recipe, :except => :recipes # MD Apr-2012. For performance, don't include :recipes
  
  def index
  end
  

  # MD Apr-2012. If there is an id parameter and that group has a welcome_page, show that otherwise show the default one
  # from the users first group, if any
  def welcome
    welcome_page = nil
    if params['id'] && (group = Group.find(params['id']))
      welcome_page = group.welcome_page
    elsif current_user && current_user.groups && (group = current_user.groups.first)
      welcome_page = group.welcome_page
    end  
    unless welcome_page.blank?
      render welcome_page
    end  
  end

  def about_us
  end

  def privacy_policy
  end
  
  def terms_of_service
  end
  
  def downloads
  end

  def faq
  end

  def sponsor
  end

  def ping
    @num_of_users = UsersPoint.where('date_added >= ?', 5.minutes.ago).count
  end

  def sign_up
    sign_out
    @user = User.new
    @user.invite_code = params[:invite_code]
  end
  
  def create_user
    @user = User.create_with_saved(params[:user], session[:temporary_user_id]) 
    if @user.errors.empty?
      sign_in(@user)
      if @user.invite_code.present?
        redirect_to '/home/select_team'
      else
        redirect_to :action => :survey
      end
    else
      render :action => :sign_up
    end
  end
  
  def recipes
    # Put the db call in the view so it isn't done when pulling from the cache 
  end
  
  #############
  # Below here, users must be logged in
  #############
    
  def edit_user
    @user = current_user
  end

  def update_user
    @user = current_user
    @user.update_and_join_group(params[:user])
    
    if @user.errors.empty?
      sign_in_direct(@user)
      flash[:notice] = 'Account information updated successfully'
      if @user.invite_code.present?
        redirect_to '/home/select_team'
      else
        redirect_to '/home/welcome'
      end
    else
      render :action => :edit_user
    end
  end
  
  # MD Apr-2012. users can belong to more than one group. However, since they just signed up they will only belong
  # to one group at this point
  def select_team
    @group = current_user.groups.first
    @group_teams = Team.where(:group_id => @group.id)
    if @group_teams.blank?
      redirect_to :action => :survey
    end
  end
  
  # MD Jun-2012. This is called after a user has been created and wants to add a team from the settings page
  def add_team
    current_user.join_team(params[:user][:team_id])
    redirect_to current_user.group_welcome_page
  end
  
  #for Blue Shield pilot only
  def survey_blueshield  
    @answers = ''
  end
  
  #for Blue Shield pilot only
  def save_survey_blueshield 
    s = Survey.new 
    s.user_id = current_user
    s.date_added = Date.today
    s.question = "Do you consider yourself a healthy eater?"
    s.answer = params[:answer1]
    s.save! 
    
    s = Survey.new 
    s.user_id = current_user
    s.date_added = Date.today
    s.question = "What do you think is your current VPG (vegetable, protein, grain) balance?"
    s.answer = "veg: " + params[:answer21] + ", protein: " + params[:answer22] + ", grains: " + params[:answer23]
    s.save! 
    
    s = Survey.new 
    s.user_id = current_user
    s.date_added = Date.today
    s.question = "On average, how many homemade lunches and dinners do you cook per week? Include homemade leftover meals. For example, I cook three dinners per week and bring leftovers for lunch the next day.  My answer is 6."
    s.answer = params[:answer3]
    s.save! 
    
    s = Survey.new 
    s.user_id = current_user
    s.date_added = Date.today
    s.question = "Where do you shop for most of your groceries?"
    s.answer = params[:answer4]
    s.save! 
    
    s = Survey.new 
    s.user_id = current_user
    s.date_added = Date.today
    s.question = "On average, how many times do you grocery shop per week?" 
    s.answer = params[:answer5]
    s.save! 
    
    flash[:notice] = "Survey Saved. Thank you!"
    redirect_to "/home/welcome"  
  end
  
  # MD Jun-2012. This will only be called when a user is first created so they will only belong to one group at this
  # time, if any.
  def survey
    survey_page = nil
    if (group = current_user.groups.first)
      survey_page = group.survey_page
    end  
    
    if survey_page.blank?
      redirect_to :action => :welcome
    else
      # MD Jun-2012. Right now we only support the blueshield survey so ignore what is in the field and go there
      redirect_to :action => :survey_blueshield
    end  
  end

  # MD Oct-2012. This is used to replace the accidently deleted ingredients_recipes
  def import_process
    @msgs = []
    first_line = true
    field_names = "id,weight,unit,important,strength,ingredient_id,recipe_id,group,description,line_num"
    params[:import_data].each_line do |line|
      if first_line
        unless line.strip == field_names
          @msgs << "First line not correct, '#{line}'"
          return
        end
        first_line = false
      else
        fields = line.split(',')
        if IngredientsRecipe.find_by_id(fields[0])
          @msgs << "IR with id=#{fields[0]} already exists"
        else
          ir = IngredientsRecipe.new
          field_names.split(',').each_with_index do |name, index|
            unless ['important', 'strength'].include?(name)
              ir[name] = fields[index]
            end
          end
          ir.save(:validate => false)
          @msgs << "Imported: #{line}"
        end
      end
    end

  end
  
  #########
  # private
  #########
  
  def background_recipe
    @background_recipe = Recipe.random_background_image
  end
  
end
