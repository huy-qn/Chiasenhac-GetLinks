require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'pry'

@agent = Mechanize.new 

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

puts "Enter url of the song"
URL = gets.chomp
DOWNLOAD_URL = "//download." + (URL.split("://")[1].split(".html"))[0] + "_download.html"
puts "Getting information from this link: " + DOWNLOAD_URL

page = @agent.get(URL)
page_download = @agent.get(DOWNLOAD_URL)
logout_link = page_download.links_with(href: "login.php?logout=true")
if logout_link.empty?
  login_site
  page_download = @agent.get(DOWNLOAD_URL)
end
downloadLinks = []
page_download.links_with(href: /downloads/).each do |link|
  downloadLinks.push(link.href)
end 

page_title = page.title.split(" - ").to_a
page_id = ((URL.split("~").to_a)[2].split(".html"))[0]

song_title = page_title[0]
artist_title = (page_title[1].split(" ~ "))[0]
lyrics = page.at('#fulllyric').at('p.genmed').text

# puts page_id 
puts song_title + "-" + artist_title
puts downloadLinks

puts "Get lyrics of this song? (Enter \"yes\" to get the lyrics)"
input = gets.chomp
if input == "yes"  
  puts lyrics
end