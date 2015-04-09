require './models/user'
require './models/tweet'
require './models/followee'
require 'csv'
require './tweet_user_server'
require './follow_server'

#load data for user table
file = File.new("./db/users.csv")
file.each_line("\n") do |row|
    columns = row.split(",")
    user_name = columns[1].chomp
    email = user_name+"@email.com"
    password = "1234"
    User_Service.register(user_name, password, email)
     
end

#load data for follow table
filename = './db/follows.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
	columns = row.split(",")
	user_id=columns[0]
	follower=columns[1]
	Follow.create(user_id: user_id, follower: follower) #db call

end

#load and create tweet_user table
filename = './db/tweets.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
	columns = row.split(",",2)
	str = columns[1]
	str =~ /(.*):(.*)?/
	last_pos = str.rindex(/\,/)
	rest = [str[0..last_pos-1].strip, str[last_pos + 1 .. str.length].strip]

	user_id= columns[0]
	text=rest[0]
	time=rest[1]
	tweet=Tweet.create(text: text,user_id: user_id) #db call
	tweet.update(created_at: time,updated_at: time)
	tweet_id= tweet[:id]
	# create an entry in tweet_user table, both follower(user_id in table) and creator_id are creator himself
	TweetUser_Service.post_tweet_user(user_id,tweet_id,user_id)
	followers = Follow_Service.get_followers(user_id)
	
	followers.each do |follower|
		#create entries for followers of the tweet owner
		TweetUser_Service.post_tweet_user(follower[:follower],tweet_id,user_id)	
	end

 end





