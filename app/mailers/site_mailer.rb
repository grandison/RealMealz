class SiteMailer < ActionMailer::Base
  default :from => "info@realmealz.com", 
          :content_type => "text/html"

  def password_reset_instructions(user)
    @password_reset_url = url_for(:controller => "users", :action => "reset_password", 
      :token => user.perishable_token, :only_path => false)
    mail(:subject => "RealMealz Password Reset Instructions",
         :to => user.email)
  end
end