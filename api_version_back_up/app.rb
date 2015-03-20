require 'sinatra'
require './app'
require 'sinatra/activerecord'
require './models/tweet'
require './models/user'
require './models/tweet_user'
require './models/followee'
require 'rspec'
require_relative 'client'

enable :sessions
get '/' do
	erb :welcome
end


get '/loggedin_root' do
	erb :loggedin_root
end

get '/tweet' do
end

get '/profile' do
	erb :profile
end

get '/mypage' do
	erb :mypage
end

get '/login' do
	if session[:log_status]==true
		redirect '/loggedin_root'
	else
		erb :login
	end
end

get '/register' do
	erb :register
	
end

get '/redirect_register' do
    #see if user_name or email already taken
	user_name_found = User.find_by(user_name: params[:user_name])
	email_found = User.find_by(email: params[:email])
	#if they're already taken, go to register, otherwise go to login
	if user_name_found || email_found
	    redirect '/register'
	else
	    redirect '/login'
	end
end


get '/user/jf' do
	erb :loggedin_userpage
end

#retrieves a tweet given a tweet id 
get '/api/v1/tweet' do

	tweet = Tweet.find_by_id(params[:id])
	
	if tweet
		tweet.to_json
	else
		error 404, {:error => "tweet not found"}.to_json
	end

end
#retrieves a user given a user id
get '/api/v1/user' do

	user = User.find_by_id(params[:id])
	
	if user
		user.to_json
	else
		error 404, {:error => "user not found"}.to_json
	end

end
#return the most recent n tweets that were made
get '/api/v1/tweet/recent/' do
	
	@number= params[:number]
	tweets = Tweet.all.order(created_at: "DESC").take(@number)
	if not @number 
		@number=30
	end
	puts @number

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
    follower_id = params[:user_id]
    user_id = session[:user_id]
    follower= User.find_by(id:follower_id)
    if !follower
        error 404, {:error => "User not found"}.to_json
    else
        follow = Follow.create(user_id:user_id,follower:follower_id)
        follow.to_json
    end

end       
get '/api/v1/user/login' do
	puts 'in login'
	@username=params[:user_name]
	@pass=params[:password]
	@user=User.find_by(user_name: @username)
	if @user #if that user exist, check the password
		if @user.password==@pass
			session[:user_name]=@username
			session[:user_id]=@user.id
			session[:log_status]=true
			#puts session[:user_name],session[:user_id],session[:log_status]
			status 200
		else
			error 403, user.errors.to_json
		end
	else
		error 403, user.errors.to_json
	end
end
get '/redirect_login' do
	@user_name=params[:user_name]
	@password=params[:password]
	puts @user_name
	response=Client.login(@user_name,@password)
	puts 'this is response'
	puts response
	puts session[:user_name]
	if response
		redirect '/loggedin_root'
	else
		redirect '/login'
	end

end
get '/api/v1/user/logout' do
	session[:user_name]=nil
	session[:user_id]=nil
	session[:log_status]=false
	puts session[:user_name],session[:log_status]

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

#unfollow the user_id that is given
get 'api/v1/user/unfollow' do
    @follower = params[:user_name]
    @user_id = sessions[:user_id]
    follower = User.find_by_id(@user_id)
    if !follower
        error 404, {:error => "User not found"}.to_json
        else
        follow = Follow.delete(user_id:@user_id,follower:@follower)
        follow.to_json
    end
    
end
