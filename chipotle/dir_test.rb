Dir.open("chipotle_html").each do |page|
	next if page == '.' or page == '..'
		puts page
end
