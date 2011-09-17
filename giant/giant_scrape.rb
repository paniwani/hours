require "hpricot"
require "open-uri"
require "net/http"
require "cgi"

def fetch(uri_str, params, limit = 10)
	# You should choose better exception.
	raise ArgumentError, 'HTTP redirect too deep' if limit == 0

	response = Net::HTTP.post_form(URI.parse(uri_str), params)
	case response
	when Net::HTTPSuccess     then response
	when Net::HTTPRedirection then fetch(response['location'], params, limit - 1)
	else
		response.error!
	end
end

params = {"where" => "", "hidden-radius" => "1","hidden-results" => "10", "find_address" => "92308"}

doc = Hpricot(fetch("http://www.starbucks.com/store-locator", params).body)

puts doc
