require "hpricot"
require "open-uri"
require "net/http"
require "cgi"

load "extract.rb"

# Setup script
HTML_FOLDER = "chipotle_dc_html"
FILE_NAME = "chipotle_dc.csv"

# Select data separator
sep = ","

file = File.open(FILE_NAME, "w")

# Create header
d = ["Mo","Tu","We","Th","Fr","Sa","Su"]
days = d.map { |i| i + "-Open" }
days = days.zip( d.map { |i| i + "-Closed" } ).flatten

file.write ["Store","Street","City","State","Zip","Phone",days].join(sep) + "\n"

# Iterate html pages
Dir.open(HTML_FOLDER).each do |page|
	next if page == '.' or page == '..'	
	
	doc = Hpricot open(Dir.pwd + "/" + HTML_FOLDER + "/" + page)
	
	# Iterate stores	
	(doc/"div.M_location_data").each do |store|
		street = extract_street store.at("table.M_location_address:nth(1)").at("tr > td:nth(1)").inner_html

		city,state,zip = extract_address store.at("table.M_location_address:nth(1)").at("tr:nth(2) > td:nth(1)").inner_html

		phone = extract_phone_number store.at("table.M_location_info").at("tr > td:nth(1)").inner_html

		hours_ar = store.search("table.M_location_info td").select { |ele| ele.inner_text =~ /[Cc]losed|(([0-9A-Za-z:]+)-([0-9A-Za-z:]+))/ }
		hours_ar.map! { |i| i.to_plain_text }
		hours = extract_hours hours_ar

		file.write ["Chipotle",street,city,state,zip,phone,hours].join(sep) + "\n"
	end	

	puts 'Scraped ' + page
end

file.close

puts "Extracted to " + FILE_NAME
