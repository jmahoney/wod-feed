require "nokogiri"
require "httparty"

site = "https://www.crossfit.com"
archive = "#{site}/workout"

response = HTTParty.get(archive)

if response.success?
  doc = Nokogiri.HTML(response.body)
  rows = doc.css("div[class='row content-container']")
  rows.each do |row|
    h = row.css("h3[class='show']").first
    permalink="#{site}#{h.children.first['href']}"
    html = h.to_html
    html << row.css("div[class='col-sm-6']").css("p").to_html

    puts permalink
    puts html
    puts "------------------------------------------------"
  end
end