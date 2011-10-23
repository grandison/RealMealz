class Integer

	##############################################################################
	## 
	## Displays time in hour and minutes
	##

	def to_time
		if self <= 60
			return self.to_s + " min"
		else
			hour = self / 60
			hour2 = hour.floor
			minutes = self - hour2*60
			return hour2.to_s + " h " + minutes.to_s + " min"
		end
	end
end


