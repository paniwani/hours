require "hpricot"
require "open-uri"
require "net/http"
require "cgi"

load "extract.rb"

# Setup script
name = "chipotle"

puts "Enter Zip Code:"
loc = gets.chomp

# Load web page
uri = "http://www.chipotle.com/en-US/find/find.aspx?loc=" + CGI::escape(loc)
doc = Hpricot(open(uri))

# Offline (for testing)
#doc = Hpricot(open("/home/paniwani/Desktop/Chipotle_54893.html"))

# Check results
stores = (doc/"div.M_location_data")

if stores.any?
	# Setup output file
	file_name = name + "_" + loc + ".csv"
	file = File.open(file_name, "w")

	# Select data separator
	sep = ","

	# Create header
	d = ["Mo","Tu","We","Th","Fr","Sa","Su"]
	days = d.map { |i| i + "-Open" }
	days = days.zip( d.map { |i| i + "-Closed" } ).flatten

	file.write ["Store","Street","City","State","Zip","Phone",days].join(sep) + "\n"

	# Iterate stores
	stores.each do |store|
		street = extract_street store.at("table.M_location_address:nth(1)").at("tr > td:nth(1)").inner_html
	
		city,state,zip = extract_address store.at("table.M_location_address:nth(1)").at("tr:nth(2) > td:nth(1)").inner_html
	
		phone = extract_phone_number store.at("table.M_location_info").at("tr > td:nth(1)").inner_html
	
		hours_ar = store.search("table.M_location_info td").select { |ele| ele.inner_text =~ /[Cc]losed|(([0-9A-Za-z:]+)-([0-9A-Za-z:]+))/ }
		hours_ar.map! { |i| i.to_plain_text }
		hours = extract_hours hours_ar

		file.write [name.capitalize,street,city,state,zip,phone,hours].join(sep) + "\n"
	end

	file.close

	puts "Extracted to " + file_name
else
	puts "No results."
end
