class InviteCode < ActiveRecord::Base
  belongs_to :groups
  
  def self.check_code(code)
    return nil if code.blank?
    find_by_invite_code(code.downcase)
  end
end
