require 'net/http'
require 'uri'
require 'nokogiri'
require 'htmlentities'

connections_feeds = {
    "connections-blog-firme" => "https://connections.croz.net/blogs/roller-ui/rendering/feed/blogjednefirme/entries/atom?lang=en_us",
}

Decoder = HTMLEntities.new

class Connections
  def initialize(widget_id, feed)
    @widget_id = widget_id
    # pick apart feed into domain and path
    @uri = URI.parse(feed)
    @path = @uri.path
  end

  def widget_id()
    @widget_id
  end

  def latest_entries()
    begin

      response = ""
      Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(@uri)
        request.basic_auth 'user ', 'password'
        response = http.request request
      end

      doc = Nokogiri::XML(response.body)

      connections_headlines = [];
      doc.remove_namespaces!
      doc.xpath('//feed/entry').each do |entry|
        title = clean_html( entry.xpath('title').text )
        summary = clean_html( entry.xpath('summary').text )
        person = clean_html( entry.xpath('author/name').text )

        connections_headlines.push({ title: title, description: summary, author: person })
        end
    rescue Exception => e
      puts e.to_s
    end
    connections_headlines
  end

  def clean_html( html )
    html = html.gsub(/<\/?[^>]*>/, "")
    html = Decoder.decode( html )
    return html
  end

end

@Connections = []
connections_feeds.each do |widget_id, feed|
  begin
    @Connections.push(Connections.new(widget_id, feed))
  rescue Exception => e
    puts e.to_s
  end
end

SCHEDULER.every '60m', :first_in => 0 do |job|
  @Connections.each do |entry|
    headlinesConn = entry.latest_entries()
    send_event(entry.widget_id, { :headlines => headlinesConn })
  end
end