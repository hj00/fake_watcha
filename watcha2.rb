require 'httparty'
require 'rest-client'
require 'json'
require 'awesome_print'

headers = {
	cookie: "__uvt=; _s_guit=94029de85265a1adb5641a12eee846abf68f85633bdfb57e72b6bf4a6dd0; _ga=GA1.2.290445583.1510902299; _gid=GA1.2.729243828.1511237884; uvts=6m4WcCF3lLBbC8mz; _guinness_session=TW5vbFlsdUphNCt1U1hVT1RCc3N0L0xGSjB4OUdmZDZqVkRhWnhCU2I3N0Z4WlVsKzNycWhQTmh2d3pCVUdvWlZRTUhTQ3dwUTY3dk5aOFhhV1Z1RUE3V1JiY0JlVThPc3d2NzFGeGNvTUg3ZCtaNExLN2hLWWVjS1YrOTF5NGlxWUF3NHN4Z2pFWkl6US80cVVieGU4eFpYUTdoK2VIQ2grOCtEaG5JMWp1MCswR0xXdzRXQWY0ZW1pL1lVdkluLS1sTjBpMndlWS9rVVBQSlQ2TkxDK0xBPT0%3D--ccecf2cb1065dd2bb7cc7f28a035a271ea96ebcf"
}
res = HTTParty.get("https://watcha.net/boxoffice.json", :headers => headers)
# res = RestClient.get("https://watcha.net/boxoffice.json", headers => {})
# ap(res.body)
watcha = JSON.parse(res.body)

# ap watcha['cards'][0]['items'][0]['item']['title']
# ap watcha['cards'][0]['items'][0]['item']['poster']['medium']
# ap watcha['cards'][0]['items'][0]['item']['interesting_comment']['text']


# title = watcha['cards'][0]['items'][0]['item']['title']
# desc = watcha['cards'][0]['items'][0]['item']['interesting_comment']['text']
# image_url = watcha['cards'][0]['items'][0]['item']['poster']['medium']
# ap title
# ap desc
# ap image_url

 
# ap watcha['cards'] 
# watcha['cards'].each do |m|
# 	title = m['items'][0]['item']['title']
# 	image_url m['items'][0]['item']['poster']['medium']
# 	desc = m['items'][0]['item']['interesting_comment']['text'] # nil인 곳이 있나봐....
# end

# 강사님 crawling -> csv
# ap watcha.keys
# ap watcha['cards'].keys
# ap watcha['cards'].first.keys
# ap watcha['cards'].first['items'].keys #array
# ap watcha['cards'].first['items'].first.keys
# ap watcha['cards'].first['items'].first['item'].keys
# ap watcha['cards'].first['items'].first['item']['title']

# title = watcha['cards'].first['items'].first['item']['title']
# image_url = watcha['cards'].first['items'].first['item']['poster']['large']
# desc = watcha['cards'].first['items'].first['item']['interesting_comment']['text']

list = watcha['cards']
ap list.class # Array Object

list.each do |item|
	movie = item["items"].first["item"]
	title = movie["title"]
	image_url = movie["poster"]["large"]
	desc = movie["interesting_comment"]["text"] if movie["interesting_comment"]
	
	CSV.open("movie_list.csv", "a+") do |csv|
		csv << [title, desc, image_url]
	end
end



# Nil class 처리 - mine

# list.each do |l|
# 	title = l['items'][0]['item']['title']
# 	image_url = l['items'][0]['item']['poster']['large']
# 	if l['items'][0]['item']['interesting_comment'].nil?
# 		desc = ""
# 	else
# 	desc = l['items'][0]['item']['interesting_comment']['text']
# 	end
# 	CSV.open("movie_list.csv", "wb") do |csv|
# 	csv << [title, image_url, desc]
# 	end

# end

# ↓ Nil class 짧게(unless)

# list.each do |l|
# 	title = l['items'][0]['item']['title']
# 	image_url = l['items'][0]['item']['poster']['large']
# 	desc = l['items'][0]['item']['interesting_comment']['text'] unless l['items'][0]['item']['interesting_comment'].nil?

# 	CSV.open("movie_list.csv", "a+") do |csv|
# 		csv << [title, image_url, desc]
# 	end
# end





