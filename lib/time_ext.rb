class Time
  
  ## Some useful methods:
  ##  Time.now
  ##  Time.now.wday
  
  ##############################
  ## Find the next requested weekday. Returns the time for end_of_day that day.
  ## Usage: Time.next(4) # thursday
  ##        Time.next(:tuesday) # tuesday
  class << self
    def next(day, from = nil)
      day = [:sunday,:monday,:tuesday,:wednesday,:thursday,:friday,:saturday].find_index(day) if day.class == Symbol
      one_day = 60 * 60 * 24
      original_date = from || now
      result = original_date
      result += one_day until result > original_date && result.wday == day 
      result.end_of_day
    end
  
  
  ################################
  ## Returns a new Time representing the end of the day, 23:59:59.999999 (.999999999 in ruby1.9)
  ## Usage: Time.now.end_of_day
  
    def end_of_day
      change(:hour => 23, :min => 59, :sec => 59, :usec => 999999.999)
    end
  end
end

#puts Time.now
#puts Time.now.wday
#puts Time.next(4) # thursday
#puts Time.next(:tuesday) # tuesday
#puts Time.now.end_of_day   