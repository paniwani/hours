require "date"

def extract_street(input)
	# Remove commas and periods
	input.gsub(/,|\./,"")
end

def extract_phone_number(input)
	# Remove non digits and match 10 digit number
	if input.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
		[$1, $2, $3].join("")
	end
end

def extract_address(input)
	# Remove whitespace after comma and match city, state, zip
	if input.gsub(/,\s+/,",").match(/^(.+)[,\\s]+(.+?)\s*(\d{5})?$/)
		[$1, $2, $3]
	end
end

def extract_hours(input)
	# Store hours as Mon-Open, Mon-Closed, Tue-Open, Tue-Closed...
	hours = Array.new(14)

	# Collect days and times
	input.each do |line|
		if line.match(/([A-Za-z]{3})-([A-Za-z]{3}) ([0-9A-Za-z:]+)-([0-9A-Za-z:]+)/) 	# Mon-Sun 11am-10pm					
			start_day, end_day, open_time, closed_time = $1, $2, $3, $4
		
		elsif line.match(/([A-Za-z]{3}) ([0-9A-Za-z:]+)-([0-9A-Za-z:]+)/) 		# Mon 11am-10pm		
			start_day, end_day, open_time, closed_time = $1, $1, $2, $3
		
		elsif line.match(/([A-Za-z]{3})-([A-Za-z]{3}) ([cC]losed)/) 			# Mon-Tue Closed
			start_day, end_day, open_time, closed_time = $1, $2, nil, nil			

		elsif line.match(/([A-Za-z]{3}) ([cC]losed)/) 					# Sun Closed		
			start_day, end_day, open_time, closed_time = $1, $1, nil, nil		
		
		else
			puts "Error extracting hours. Line: " + line
		end

		# Convert days to numbers, Mon (1), Tue (2)...
		start_day = day_to_num(start_day)
		end_day = day_to_num(end_day)

		(start_day..end_day).each do |i|
			hours[2*(i-1)]   = open_time.nil?   ? "CLOSED" : time_to_24(open_time)
			hours[2*(i-1)+1] = closed_time.nil? ? "CLOSED" : time_to_24(closed_time)
		end		
	end

	return hours
end

def day_to_num(day)
	DateTime.parse(day).strftime("%u").to_i
end

def time_to_24(t)
	DateTime.parse(t).strftime("%H:%M")
end
