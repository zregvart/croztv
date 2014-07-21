require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'xD3RJtMPS6Ke9fmvWg0kXOhTz'
  config.consumer_secret = 'bQkmfSEyAt141ZLCd5y1CCPr4G2wirhbWSUoJDKEE7ZR0s9j5B'
  config.access_token = '2714604705-RqWhzlDOizEicwE0NGDWv53xNQOdvd5Wlha2iNX'
  config.access_token_secret = '0DtFjatMvlWxRwclh6fW3QCRjE21FACxDSQC4ggp6q6qr'
end

search_term = URI::encode('croztv')

SCHEDULER.every '1m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")

    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', comments: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end