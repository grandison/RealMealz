class AddGroupWelcomePage < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.string :welcome_page
    end
  end
end
