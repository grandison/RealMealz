require 'csv'

#Usage: load ‘parsers/import_skills.rb’  #adds the skills using the skills.csv file
#make sure skills.csv file is comma delimited, if containing old record name then has the updated version of the data because the file will update the data
#csv must come in the column order of scategory_id, name, description, level, video_link
#make sure scategory table has id=1, name=technique, id=2, name=ingredient

first_row = 1   #use for skipping the first row

CSV.foreach("parsers/skills.csv") do |row|
	if first_row == 1
		first_row = 0
	else
		@s = Skill.find_by_name(row[2])
		if ( @s == nil) ## does not exist, add new record
			 puts "Adding:  #{row} \n"
			 @s=Skill.new
		else
			 puts "Skills table already contains #{row[2]},  Now Updating  \n"	 
		end
		@s.scategory_id = row[1]
		@s.name = row[2]
		@s.description=row[3]
		@s.level = row[4]
		@s.video_link = row[5]
		@s.save!
	end
end
