require 'rubygems'
require 'mechanize'
require 'open-uri'
require_relative 'accent_strip.rb'
# require 'pry'

@agent = Mechanize.new 
@rencentKeywords = ["a","b","c"]

def login_site
  login_url = "http://chiasenhac.com/login.php"
  page_login = @agent.get(login_url)
  login_form = page_login.form_with(:action => "login.php")
  login_form['username'] = "quochuy.nguyen107"
  login_form['password'] = "xaichung2015"
  login_form['autologin'] = "on"
  login_form['redirect'] = ""
  login_form['login'] = "Đăng Nhập"
  page_logged = login_form.submit
end 

def searchAndOpenFirstResult
	i = 0
	while i < 3 do
		puts @rencentKeywords[i]
		i+=1
	end
	puts "Nhập từ khóa"
	keyword = gets.chomp
	@rencentKeywords.push(keyword.to_s);
	keyword = keyword.strip_accents
	searchUrl = "search.chiasenhac.vn/search.php?s=" + keyword
	page = @agent.get("http://search.chiasenhac.vn/search.php?s=" + keyword)
	link = page.link_with(:dom_class => "musictitle")
	page = link.click
	return page.uri.to_s
end

# puts "Enter url of the song"
def getDownloadLinks
	url = searchAndOpenFirstResult
	downloadUrl = "//download." + (url.split("://")[1].split(".html"))[0] + "_download.html"
	puts "Getting information from this link: " + downloadUrl

	page = @agent.get(url)
	page_download = @agent.get(downloadUrl)
	logout_link = page_download.links_with(href: "login.php?logout=true")
	if logout_link.empty?
	  login_site
	  page_download = @agent.get(downloadUrl)
	end
	downloadLinks = []
	page_download.links_with(href: /downloads/).each do |link|
	  downloadLinks.push(link.href)
	end 

	page_title = page.title.split(" - ").to_a
	page_id = ((url.split("~").to_a)[2].split(".html"))[0]

	song_title = page_title[0]
	artist_title = (page_title[1].split(" ~ "))[0]
	lyrics = page.at('#fulllyric').at('p.genmed') ? page.at('#fulllyric').at('p.genmed').text : "Chưa cập nhật lời bài hát"

	# puts page_id 
	puts song_title + "-" + artist_title
	puts downloadLinks

	puts "Play?"
	input = gets.chomp
	if input == "yes"  
  	puts lyrics
  	system 'open -a iTunes ' + "\"#{downloadLinks[0]}\""
	end
end

getDownloadLinks
