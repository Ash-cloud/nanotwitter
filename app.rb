require 'sinatra'
require 'sinatra/activerecord'
#require_relative 'server'
require './config/environments'
require_relative 'tweet_server'
require_relative 'user_server'
require_relative 'follow_server'
require_relative 'tweet_user_server'


enable :sessions
configure :production do
  require 'newrelic_rpm'
end
after { ActiveRecord::Base.connection.close }
#loadio code for TA
get '/loaderio-ceac0dc59fc5754aa4affe8ba2bf6242/' do
  "loaderio-ceac0dc59fc5754aa4affe8ba2bf6242"
end

#loadio code for us
get '/loaderio-2c5b20f8cbc30dfc026cc8d80ceb4a67/' do
    erb :loader
end

#welcome page
get '/' do
	if session[:log_status]==true
		redirect '/loggedin_root'
	else 
		@tweets = Tweet_Service.getRecentTweets()
		erb :welcome
	end
end

#this router show erbs depending on the status of current user. It require parameters :user_id to render the view for userpage.
#if user is logged in and user_id in session is equal to parameter, then show mypage(visiting his/her own page)
#if user is logged in while user_id in session are different from what in parameter, show loggedin usrepage (visiting other people's page)
#if user is unlogged in then the page shows will be slightly different from the second situation(no follow and unfollow, login/register button)
get '/user_page' do
    #@page_owner_id = session[:owner_id]
	@page_owner_id=params[:user_id]
	if @page_owner_id.to_s==session[:user_id].to_s #logged in and is the owner, show mypage.erb
		redirect '/mypage'
	else #session[:log_status] #logged in while not the owner, will have follow and unfollow button
		redirect '/show_userpage?owner_id='+@page_owner_id.to_s
	end
end
get '/login_payload' do
	erb :login_payload
end
get '/follow_payload' do 
	erb :follow_payload
end
# Show the stream: all the tweet have posted by that pageowner
get '/mypage' do
	@tweets=Tweet_Service.get_stream(session[:user_id])
	erb :mypage
end

#Create timeline and give recommendations for user to follow
get '/loggedin_root' do
	@tweets=User_Service.timeline(session[:user_id])
	@recommendations=User_Service.get_users_to_follow(session[:user_id])
	erb :loggedin_root, :locals => {'recommendations' => @recommendations}
end

#Viwing other people's page see what they have posted and do follow and unfollow action
get '/show_userpage' do
	puts 'in show user page'
	@user_id=session[:user_id]
	@owner_id=params[:owner_id] #was params
	@tweets=Tweet_Service.get_stream(params[:owner_id])
	@owner_name=User.find_by(id:params[:owner_id]).user_name #db call
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
	TweetUser_Service.add_old_tweets(@follower_id,@followee_id)
	#redirect back
	redirect '/empty'
end
post '/unfollow' do
	@followee_id=params[:followee_id]
	@follower_id=params[:follower_id]
	Follow_Service.unfollow(@follower_id,@followee_id)
	TweetUser_Service.delete_old_tweets(@follower_id,@followee_id)
	#redirect back
	redirect '/empty'

end
#check if user could login or not
get '/redirect_login' do
	@user_name=params[:user_name]
	@password=params[:password]
	response=User_Service.login(@user_name,@password)
	if response=='logged_in'
	       	session[:user_name]=@user_name
		session[:user_id]=User.find_by(user_name: @user_name).id #db call
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

#retrieves a tweet given a tweet id 
get '/api/v1/tweet' do
    #tweet = Tweet.find_by_id(params[:id])
    tweet = Tweet_Service.getTweetsByID(params[:id])
	
	if tweet
		tweet.to_json
	else
		error 404, {:error => "tweet not found"}.to_json
	end

end
#retrieves a user given a user id
get '/api/v1/user' do
    #user = User.find_by_id(params[:id])
    user = User_Service.getUserByID(params[:id])
	
	if user
		user.to_json
	else
		error 404, {:error => "user not found"}.to_json
	end

end
#return the most recent n tweets that were made
get '/api/v1/tweet/recent/' do
	
	@number= params[:number]
    #tweets = Tweet.all.order(created_at: "DESC").take(@number)
	if not @number 
		@number=30
	end
	puts @number
    
    tweets = Tweet.getRecentTweets(@number)
    
	if tweets 
		tweets.to_json
	else
		error 123, {:error => "not a valid number"}.to_json
	end
end
#return the most recent tweets of a specified user in descending order
#they are what the user have tweeted
get '/api/v1/users/*/tweets' do
    #@user_id = params[:user_id]
    @user_id = params[:splat].first.split("/")
    tweets = Tweet_Service.where(user_id:@user_id).order(created_at: "DESC").take(100)
    if tweets
        tweets.to_json
    else
        error 404, {:error => "problems"}.to_json
    end
end
#return a list of a given user's followers
get '/api/v1/user/follower' do
    @user_id = session[:user_id]
    follows = Follow_Service.where(user_id:@user_id)
    if follows
        follows.to_json
    else
        error 404, {:error => "problems"}.to_json
    end
end
#find a specified user's follower and return a list of that follower's
#tweets
get '/api/v1/user/follower/*/tweet' do
    @user_id = session[:user_id]
    @follower_id = params[:splat].second.split("/")
    follow = Follow.where(user_id:@user_id,follower:@follower_id) #db call
    if follow.length > 0 #meaning follower for that user was found
        followers_tweets = Tweet.where(user_id:@follower_id).order(created_at:"DESC").take(100) #db call
        followers_tweets.to_json
    else
        error 404, {:error => "User did not have this follower"}.to_json
    end
    
end 
#change the user's password (might add other things to change later)
#this will be a put, it's a get right now to test it
get '/api/v1/user/*/modify' do
    @user_id = session[:user_id]
    @password = params[:password]
    
    user = User.find_by(id:@user_id) #db call
    if !user
        error 404, {:error => "User not found"}.to_json
    else
        if @password
            user.update(password:@password)
            user.to_json
        else
            error 404, {:error => "no password parameter"}.to_json
        end
    end
end 

#follow the user_id that is given (will be a post)
get '/api/v1/user/follow' do
    follower_id = session[:user_id]
    followee_id = params[:user_id]
    followee= User.find_by(id:followee_id) #db call
    if !followee
        error 404, {:error => "User not found"}.to_json
    else
        follow = Follow.create(user_id:followee_id,follower:follower_id) #db call
        follow.to_json
    end

end       
#unfollow the user_id that is given
get '/api/v1/user/unfollow' do
    follower_id = session[:user_id]
    followee_id = params[:user_id]
    followee = User.find_by(id:followee_id) #db call
    if !followee
        error 404, {:error => "User not found"}.to_json
    else
        f = Follow.where(user_id:followee_id,follower:follower_id) #db call
        Follow.delete(f) #db call
        #not sure what this should return in terms of JSON
    end
    
end     
get '/api/v1/user/login' do

end


post '/api/v1/user/register' do
	begin
		@email=params[:email]
		@user_name=params[:user_name]
		@pass=params[:password]
		user = User.create(email:@email,user_name:@user_name,password:@pass) #db call
		if user.valid?
			user.to_json
		else
			error 400, user.errors.to_json 
		end
	rescue => e
		error 400, e.message.to_json
	end
end

#post a tweet, add tweet to db, add tweet to user and followers timelines
post '/api/v1/tweet' do
	begin
		@text=params[:tweet_content]
		@user_id=session[:user_id]
		tweet = Tweet.create(text:@text,user_id:@user_id) #db call

		@tweet_id= tweet[:id]
		tweet_user = TweetUser.create(tweet_id:@tweet_id,user_id:@user_id) #db call
		
		followers = Follow.where(user_id: @user_id) #db call
		
		followers.each do |follower|

			TweetUser.create(user_id: follower[:follower], tweet_id: @tweet_id)	#db call
		end
		
		status 200
	rescue => e
		error 400, e.message.to_json
	end
	
	
end

post '/tweet' do

	@text=params[:tweet_content]
	@user_id=session[:user_id]
	@sent_from=params[:path]

	tweet = Tweet_Service.post_tweet(@text,@user_id)

	@tweet_id= tweet[:id]

	TweetUser_Service.post_tweet_user(@user_id,@tweet_id,@user_id) 

	followers = Follow_Service.get_followers(@user_id)

	followers.each do |follower|

		TweetUser_Service.post_tweet_user(follower[:follower],@tweet_id,@user_id)	
	end

	if @sent_from == '/loggedin_root'
		redirect '/loggedin_root'
	elsif @sent_from == '/mypage'
		redirect '/mypage'
	else 
		puts "You can't tweet from here"
	end
	

end


