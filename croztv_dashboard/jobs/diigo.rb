require 'net/http'
require 'uri'
require 'nokogiri'
require 'htmlentities'

news_feeds = {
    "croz-diigo" => "https://groups.diigo.com/group/croz-dev/rss/57188/aaa51f70210f67386a278f56f20bfdf9",
}

Decoder = HTMLEntities.new

class Diigo
  def initialize(widget_id, feed)
    @widget_id = widget_id
    # pick apart feed into domain and path
    uri = URI.parse(feed)
    @path = uri.path
    @http = Net::HTTP.new(uri.host)
  end

  def widget_id()
    @widget_id
  end

  def latest_headlines()
    response = @http.request(Net::HTTP::Get.new(@path))
    doc = Nokogiri::XML(response.body)
    news_headlines = [];
    doc.xpath('//channel/item').each do |news_item|
      title = clean_html( news_item.xpath('title').text )
      summary = clean_html( news_item.xpath('description').text)
      news_headlines.push({ title: title, description: summary })
    end
    news_headlines
  end

  def clean_html( html )
    html = html.gsub(/<\/?[^>]*>/, "")
    html = Decoder.decode( html )
    return html
  end

end

@Diigo = []
news_feeds.each do |widget_id, feed|
  begin
    @Diigo.push(Diigo.new(widget_id, feed))
  rescue Exception => e
    puts e.to_s
  end
end

SCHEDULER.every '60m', :first_in => 0 do |job|
  @Diigo.each do |news|
    headlines = news.latest_headlines()
    send_event(news.widget_id, { :headlines => headlines })
  end
end