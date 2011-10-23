class SlidingScalesController < ApplicationController
    active_scaffold :sliding_scales do |config|
      config.columns = [:name1, :name2]
    end
end
