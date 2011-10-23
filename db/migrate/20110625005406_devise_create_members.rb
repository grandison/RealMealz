class DeviseCreateMembers < ActiveRecord::Migration
  def self.up
    change_table(:members) do |t|
      # Email already exists so do database_authenticatable manually
      #t.database_authenticatable :null => false 
      t.string :encrypted_password, :null => false, :default => "", :limit => 128
      t.recoverable
      t.rememberable
      t.trackable
      t.encryptable
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable
      t.timestamps
    end

    add_index :members, :email,                :unique => true
    add_index :members, :reset_password_token, :unique => true
    add_index :members, :confirmation_token,   :unique => true
    add_index :members, :unlock_token,         :unique => true
    add_index :members, :authentication_token, :unique => true
  end

  def self.down
    remove_index :members, :email
    remove_index :members, :reset_password_token
    remove_index :members, :confirmation_token
    remove_index :members, :unlock_token
    remove_index :members, :authentication_token

    change_table(:members) do |t|
      t.remove :encrypted_password
      t.remove :password_salt
      t.remove :authentication_token
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
      t.remove :failed_attempts
      t.remove :unlock_token
      t.remove :locked_at
      t.remove :created_at
      t.remove :updated_at
    end
  end
end
