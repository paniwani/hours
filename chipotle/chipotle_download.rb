BASE_LIST_URL = 'http://www.chipotle.com/en-US/find/find.aspx?loc=washington%20dc&PageID='

LAST_PAGE_NUMBER = 4

LIST_PAGES_SUBDIR = 'chipotle_html'

Dir.mkdir(LIST_PAGES_SUBDIR) unless File.exists?(LIST_PAGES_SUBDIR)

for page_number in 0..LAST_PAGE_NUMBER        

	system("wget '#{BASE_LIST_URL}#{page_number}' -O #{LIST_PAGES_SUBDIR}/#{page_number}.html")

        puts "Copied page #{page_number}"
        
        sleep 4 
end
