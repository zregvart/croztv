require 'net/http'
require 'json'
 
current = 0
SCHEDULER.every '10s', :first_in => 0 do
  last = current

  http = Net::HTTP.new("build.lan.croz.net", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new("/computer/api/json?pretty=true")
  request.basic_auth("croztv", "xxx")
  response = http.request(request)

  computers = JSON.parse(response.body)

  current = computers["busyExecutors"]

  send_event(:jenkins_busy, { current: current, last: last })
end
