require "nokogiri"
require "httparty"
require "sinatra"
require "date"

items = []
last_fetched = Date.today - 7

get "/" do
  if  items.empty? || last_fetched < DateTime.now - 0.5
    items = fetch_and_parse
    last_fetched = DateTime.now
  end

  feed = {
    version: "https://jsonfeed.org/version/1",
    title: "Workout Of The Day Feed",
    home_page_url: "https://www.crossfit.com/workout",
    feed_url: "http://wod-feed.cheerschopper.com",
    items: items
  }

  content_type "application/json"
  feed.to_json
end

def fetch_and_parse
  response = HTTParty.get("https://www.crossfit.com/workout")

  if response.success?
    doc = Nokogiri.HTML(response.body)

    feed = []

    rows = doc.css("div[class='row content-container']")

    rows.each do |row|
      header = row.css("h3[class='show']").first
      permalink="https://www.crossfit.com#{header.children.first['href']}"
      title = header.text
      html = header.to_html
      html << row.css("div[class='col-sm-6']").css("p").to_html
      feed << {id: permalink, url: permalink, content_html: html, title: title, date_published: extract_date(header.text)}
    end

    return feed
  end
end

def extract_date(header_text)
  md = /([0-9]{2})([0-9]{2})([0-9]{2})/.match(header_text)
  return DateTime.parse("20#{md[1]}-#{md[2]}-#{md[3]}")
end




