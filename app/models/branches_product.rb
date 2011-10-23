class BranchesProduct < ActiveRecord::Base
  belongs_to :branch
  belongs_to :product
end
