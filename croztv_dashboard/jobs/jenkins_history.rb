require 'net/http'
require 'rss'
 
current = 0
SCHEDULER.every '10s', :first_in => 0 do
  last = current

  http = Net::HTTP.new("build.lan.croz.net", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new("/view/All/rssLatest")
  request.basic_auth("croztv", "xxx")
  response = http.request(request)

  feed = RSS::Parser.parse(response.body)

  items = feed.items.collect do |item|
    title = item.title.content
    { 
      label: title.partition(" (").first, 
      value: title[/\(.*?\)/],
      time:  item.updated.content.to_i 
    }
  end.sort_by { |i| -i[:time] }.first(8)

  send_event(:jenkins_history, { items: items })
end
