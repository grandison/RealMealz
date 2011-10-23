class CreateAuthlogic < ActiveRecord::Migration

  def self.up
    change_table :users do |t|
      t.remove :login, :password, :reset_password_token, :confirmation_token, :unlock_token, :authentication_token
      t.remove :reset_password_sent_at, :remember_created_at, :confirmed_at, :confirmation_sent_at, :locked_at
      t.rename :encrypted_password, :crypted_password
      t.string :persistence_token
      t.rename :sign_in_count, :login_count
      t.rename :failed_attempts, :failed_login_count
      t.datetime :last_request_at
      t.rename :last_sign_in_at, :last_login_at
      t.rename :current_sign_in_at, :current_login_at
      t.rename :last_sign_in_ip, :last_login_ip
      t.rename :current_sign_in_ip, :current_login_ip
      t.index :email
      t.index :persistence_token
      t.index :last_request_at
    end
  end

  def self.down

    change_table :users do |t|
      t.remove_index :email
      t.remove_index :persistence_token
      t.remove_index :last_request_at
      t.string :login, :password,:reset_password_token, :confirmation_token, :unlock_token, :authentication_token
      t.date_time :reset_password_sent_at, :remember_created_at, :confirmed_at, :confirmation_sent_at, :locked_at
      t.string :password
      t.rename :crypted_password, :encrypted_password
      t.remove :persistence_token
      t.rename :login_count, :sign_in_count
      t.rename :failed_login_count, :failed_attempts
      t.remove :last_request_at
      t.rename :last_login_at, :last_sign_in_at
      t.rename :current_login_at, :current_sign_in_at
      t.rename :last_login_ip, :last_sign_in_ip
      t.rename :current_login_ip, :current_sign_in_ip
    end
  end
end
