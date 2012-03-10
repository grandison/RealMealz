class ShopListMailer < ActionMailer::Base
  default from: "RealMealz <shop_list@realmealz.com>"
  
   def shop_list_email(user, item_list)
    @user = user
    @item_list = item_list
    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(:to => email_with_name, :subject => "RealMealz Shopping List")
  end
end
