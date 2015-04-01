require 'sinatra'
require 'sinatra/activerecord'
require_relative 'server'
require './config/environments'

configure :production do
  require 'newrelic_rpm'
end

get '/loaderio-ceac0dc59fc5754aa4affe8ba2bf6242/' do
  "loaderio-ceac0dc59fc5754aa4affe8ba2bf6242"
end

enable :sessions
get '/loaderio-2c5b20f8cbc30dfc026cc8d80ceb4a67/' do
    erb :loader
end
get '/' do
	if session[:log_status]==true
		redirect '/loggedin_root'
	else 
		@tweets = Service.getRecentTweets()
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
	    #if params[:path] == 'profile'
	    puts '############### page owner id is' + @page_owner_id.to_s
		redirect '/show_userpage?owner_id='+@page_owner_id.to_s
	end
end


get '/mypage' do
	@tweets=Service.get_stream(session[:user_id])
	erb :mypage
end
get '/loggedin_root' do
	@tweets=Service.timeline(session[:user_id])
	@recommendations=Service.get_users_to_follow(session[:user_id])
	erb :loggedin_root, :locals => {'recommendations' => @recommendations}
end

get '/show_userpage' do
	puts 'in show user page'
	@user_id=session[:user_id]
	@owner_id=params[:owner_id] #was params
	@tweets=Service.get_stream(params[:owner_id])
	@owner_name=User.find_by(id:params[:owner_id]).user_name
	@log_status=session[:log_status]
	@followed_flag=Service.followed?(@owner_id,@user_id)
	erb :show_userpage
end


get '/profile' do
    users_followed = Service.followers(session[:user_id])
    users_followed.each do |followee|
        puts "follows #{followee.user_id}"
    end 
    user_name = session[:user_name]
    email = Service.get_email_by_id(session[:user_id])
	erb :profile, :locals => {'user_name' => user_name, 'users_followed' => users_followed, 'email' => email}
end


get '/login' do
	if session[:log_status]==true
		redirect '/loggedin_root'
	else
		erb :login
	end
end

get '/logout' do

	session[:user_name]=nil
	session[:user_id]=nil
	session[:log_status]=false
	redirect '/'
end
get '/register' do
	erb :register
end
post '/follow' do
	@followee_id=params[:followee_id]
	@follower_id=params[:follower_id]
	Service.follow(@follower_id,@followee_id)
	redirect back
end
post '/unfollow' do
	@followee_id=params[:followee_id]
	@follower_id=params[:follower_id]
	Service.unfollow(@follower_id,@followee_id)
	redirect back

end
get '/redirect_login' do
	@user_name=params[:user_name]
	@password=params[:password]
	response=Service.login(@user_name,@password)
	if response=='logged_in'
	       	session[:user_name]=@user_name
		session[:user_id]=User.find_by(user_name: @user_name).id
		session[:log_status]=true
		redirect '/loggedin_root'
	else
		redirect '/login'
	end

end
get '/redirect_register' do
    message = Service.register(params[:user_name],params[:password],params[:email])
	if message == 'ok'
	    redirect '/login'
	else
	    redirect '/register'
	end
end

#retrieves a tweet given a tweet id 
get '/api/v1/tweet' do
    #tweet = Tweet.find_by_id(params[:id])
    tweet = Service.getTweetsByID(params[:id])
	
	if tweet
		tweet.to_json
	else
		error 404, {:error => "tweet not found"}.to_json
	end

end
#retrieves a user given a user id
get '/api/v1/user' do
    #user = User.find_by_id(params[:id])
    user = Service.getUserByID(params[:id])
	
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
    
    tweets = Service.getRecentTweets(@number)
    
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
    tweets = Tweet.where(user_id:@user_id).order(created_at: "DESC").take(100)
    if tweets
        tweets.to_json
    else
        error 404, {:error => "problems"}.to_json
    end
end
#return a list of a given user's followers
get '/api/v1/user/follower' do
    @user_id = session[:user_id]
    follows = Follow.where(user_id:@user_id)
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
    follow = Follow.where(user_id:@user_id,follower:@follower_id)
    if follow.length > 0 #meaning follower for that user was found
        followers_tweets = Tweet.where(user_id:@follower_id).order(created_at:"DESC").take(100)
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
    
    user = User.find_by(id:@user_id)
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
    followee= User.find_by(id:followee_id)
    if !followee
        error 404, {:error => "User not found"}.to_json
    else
        follow = Follow.create(user_id:followee_id,follower:follower_id)
        follow.to_json
    end

end       
#unfollow the user_id that is given
get '/api/v1/user/unfollow' do
    follower_id = session[:user_id]
    followee_id = params[:user_id]
    followee = User.find_by(id:followee_id)
    if !followee
        error 404, {:error => "User not found"}.to_json
    else
        f = Follow.where(user_id:followee_id,follower:follower_id)
        Follow.delete(f)
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
		user = User.create(email:@email,user_name:@user_name,password:@pass) 
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
		tweet = Tweet.create(text:@text,user_id:@user_id)

		@tweet_id= tweet[:id]
		tweet_user = TweetUser.create(tweet_id:@tweet_id,user_id:@user_id)
		
		followers = Follow.where(user_id: @user_id)
		
		followers.each do |follower|

			TweetUser.create(user_id: follower[:follower], tweet_id: @tweet_id)	
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

	tweet = Service.post_tweet(@text,@user_id)

	@tweet_id= tweet[:id]

	Service.post_tweet_user(@user_id,@tweet_id)

	followers = Service.get_followers(@user_id)

	followers.each do |follower|

		Service.post_tweet_user(follower[:follower],@tweet_id)	
	end

	if @sent_from == '/loggedin_root'
		redirect '/loggedin_root'
	elsif @sent_from == '/mypage'
		redirect '/mypage'
	else 
		puts "You can't tweet from here"
	end
	

end


