require './models/user'
require './models/tweet'
require './server.rb'
File.open("./db/tweets.csv").readlines.each do |line|
  CSV.parse do |line|
    user_id,text, time = line
    @tweet = Tweet.create(text: tweet_content,user_id: user_id,created_at: time,updated_at: ime)
    
  end
end

