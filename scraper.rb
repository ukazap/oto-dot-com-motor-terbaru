# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

page = 1

loop do
  list_page = agent.get("https://www.oto.com/motor-populer?itemsOnly=true&sort=populer&page=#{page}")
  puts list_page.title
  links = list_page.search('.filtercars li.item .card-title a').map {|l| l.attr(:href)  }

  links.each do |link|
    detail_page = agent.get(link)
    puts detail_page.title

    breadcrumb_link = detail_page.search('.breadcrumb li')

    features = {
      "name" => breadcrumb_link[3].content,
      "brand" => breadcrumb_link[2].content
    }

    detail_page.search('.feature-list td').each_slice(2) do |feature|
      name, value = feature
      features[name.content.strip.downcase.gsub(" ", "_")] = value.content
    end

    features["automatic_transmission"] = features['jenis_transmisi'].strip != 'Manual'

    ScraperWiki.save_sqlite(["name"], features)
  end

  break if links.empty? || list_page('.loadmorebtn').nil?

  page += 1
end

puts "done"
