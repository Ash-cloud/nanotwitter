require 'sinatra'
require 'sinatra/activerecord'
require 'faker'
#require_relative 'server'
require './config/environments'
require_relative 'tweet_server'
require_relative 'user_server'
require_relative 'follow_server'
#require_relative 'tweet_user_server'

ActiveRecord::Base.logger=Logger.new(STDOUT)

enable :sessions
configure :production do
  require 'newrelic_rpm'
end
#configuring redis cloud
configure do
    require 'redis'
    uri = URI.parse("redis://rediscloud:Tm4jpeBjkvIAO2Yp@pub-redis-16637.us-east-1-2.3.ec2.garantiadata.com:16637")
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    $redis.flushall
    tweets = Tweet_Service.getRecentTweets()
    $redis.set("cached-users",JSON.generate([]))
    $redis.set("100-tweets",JSON.generate(tweets))
end

#after { ActiveRecord::Base.connection.close }
#loadio code for TA
get '/loaderio-ceac0dc59fc5754aa4affe8ba2bf6242/' do
	"loaderio-ceac0dc59fc5754aa4affe8ba2bf6242"
end

#loadio code for andy
get '/loaderio-2c5b20f8cbc30dfc026cc8d80ceb4a67/' do
	"loaderio-2c5b20f8cbc30dfc026cc8d80ceb4a67"
end
#loadio code for jinfeng lin
get '/loaderio-e0344b47614f74b76ef47efc30256a34/' do
	"loaderio-e0344b47614f74b76ef47efc30256a34"
end
#welcome page
get '/' do   #Refactoring Done
	if session[:log_status]==true
		redirect '/loggedin_root'
	else 
		#tweets = Tweet_Service.getRecentTweets()#tweets now are array!!
		tweets=JSON.parse($redis.get("100-tweets"))	
		@user_id_array,@user_name_array,@created_time_array,@text_array= Tweet_Service.create_Tweets_attribute_arrays(tweets)
		erb :welcome
	end
end

#this router show erbs depending on the status of current user. It require parameters :user_id to render the view for userpage.
#if user is logged in and user_id in session is equal to parameter, then show mypage(visiting his/her own page)
#if user is logged in while user_id in session are different from what in parameter, show loggedin usrepage (visiting other people's page)
#if user is unlogged in then the page shows will be slightly different from the second situation(no follow and unfollow, login/register button)

get '/user_page' do
    	@page_owner_id=params[:user_id]
	if @page_owner_id.to_s==session[:user_id].to_s #logged in and is the owner, show mypage.erb
		redirect '/mypage'
	else #session[:log_status] #logged in while not the owner, will have follow and unfollow button
		redirect '/show_userpage?owner_id='+@page_owner_id.to_s
	end
end
get '/login_payload' do
	erb :login_payload, layout:false
end
get '/follow_payload' do 
	erb :follow_payload, layout:false
end
# Show the stream: all the tweet have posted by that pageowner
get '/mypage' do  #Refract Done
	tweets=Tweet_Service.get_stream(session[:user_id])
	@user_id_array,@user_name_array,@created_time_array,@text_array= Tweet_Service.create_Tweets_attribute_arrays(tweets)
	erb :mypage
end

#Create timeline and give recommendations for user to follow
get '/loggedin_root' do
	user_id = session[:user_id]
	cached_users = JSON.parse($redis.get("cached-users"))
	puts "cached users:#{cached_users}"
	if $redis.exists(user_id)
		puts "here"
		tweets = JSON.parse($redis.get(user_id))	
	else
		puts "not cached"
		tweets=Tweet_Service.timeline(session[:user_id])
		cached_users.push (user_id)
		$redis.set("cached-users",cached_users)
		$redis.set(user_id, JSON.generate(tweets))
	end
	@user_id_array,@user_name_array,@created_time_array,@text_array=Tweet_Service.create_Tweets_attribute_arrays(tweets)
	@recommendations=User_Service.get_users_to_follow().pluck(:id,:user_name)#0->id,1->username

	erb :loggedin_root
end

#Viwing other people's page see what they have posted and do follow and unfollow action
get '/show_userpage' do
	puts 'in show user page'
	@user_id=session[:user_id]
	@owner_id=params[:owner_id] #was params
	tweets=Tweet_Service.get_stream(params[:owner_id])#tweets now are arrays
	@user_id_array,@user_name_array,@created_time_array,@text_array= Tweet_Service.create_Tweets_attribute_arrays(tweets)
	@owner_name=User.find_by(id:@owner_id).user_name
	@log_status=session[:log_status]
	@followed_flag=Follow_Service.followed?(@owner_id,@user_id)
	erb :show_userpage
end

#Show profile: the users he have followed and the email he used to register
get '/profile' do
    users_followed = Follow_Service.followers(session[:user_id])
    users_followed.each do |followee|
        puts "follows #{followee.user_id}"
    end 
    user_name = session[:user_name]
    email = User_Service.get_email_by_id(session[:user_id])
	erb :profile, :locals => {'user_name' => user_name, 'users_followed' => users_followed, 'email' => email}
end

#login, create session
get '/login' do
	if session[:log_status]==true
		redirect '/loggedin_root'
	else
		erb :login
	end
end

#logout, clean session
get '/logout' do

	session[:user_name]=nil
	session[:user_id]=nil
	session[:log_status]=false
	redirect '/'
end
#register a new account
get '/register' do
	erb :register
end

post '/follow' do
	@followee_id=params[:followee_id]
	@follower_id=params[:follower_id]
	Follow_Service.follow(@follower_id,@followee_id)
	#TweetUser_Service.add_old_tweets(@follower_id,@followee_id)
	redirect back
	#redirect '/empty'
end
post '/unfollow' do
	@followee_id=params[:followee_id]
	@follower_id=params[:follower_id]
	Follow_Service.unfollow(@follower_id,@followee_id)
	#TweetUser_Service.delete_old_tweets(@follower_id,@followee_id)
	redirect back
	#redirect '/empty'

end
#check if user could login or not
get '/redirect_login' do
	@user_name=params[:user_name]
	@password=params[:password]
	response,id=User_Service.login(@user_name,@password)
	if response=='logged_in'
	       	session[:user_name]=@user_name
		session[:user_id]=id
		session[:log_status]=true
		redirect '/loggedin_root'
	else
		redirect '/login'
	end

end
get '/empty' do
end
#check if register successfully, if not back to register page
get '/redirect_register' do
    message = User_Service.register(params[:user_name],params[:password],params[:email])
	if message == 'ok'
	    redirect '/login'
	else
	    redirect '/register'
	end
end

post '/tweet' do
	@text=params[:tweet_content]
	@user_id=session[:user_id]
	Tweet_Service.post_tweet(@text,@user_id)
	redirect back	
end

get '/test_tweet' do
	#user_name="test_user"
	user_id=1001
	tweet= Faker::Hacker.say_something_smart
	Tweet_Service.post_tweet(tweet,user_id)
end

get '/test_follow' do
	candidate = User.limit(1).order("RANDOM()")
	#user_id=User.find_by(user_name: "test_user").id
	user_id=1001
	if Follow_Service.followed?(candidates.id,user_id)
		Follow_Service.unfollow(user_id,candidate.id)
	else
		Follow_Service.follow(user_id,candidate.id)
	end
	
end

get '/test_profile' do
	#tweets=Tweet_Service.timeline(session[:user_id])
	user_id =1001
	cached_users = JSON.parse($redis.get("cached-users"))
	puts "cached users:#{cached_users}"
	if $redis.exists(user_id)
		tweets = JSON.parse($redis.get(user_id))
		puts "There are totally #{tweets.length} tweets"
	else	
		tweets=Tweet_Service.timeline(1001)
		cached_users.push (user_id)
		$redis.set("cached-users",cached_users)
		$redis.set(user_id, JSON.generate(tweets))
		puts "There are totally #{tweets.length} tweets"
	end
	#tweets=Tweet_Service.timeline(1001)
	@user_id_array,@user_name_array,@created_time_array,@text_array=Tweet_Service.create_Tweets_attribute_arrays(tweets)
	erb :test_profile


end

get '/reset' do
    Tweet.delete_all(user_id: 1001)
    Follow.delete_all(follower: 1001)
end
