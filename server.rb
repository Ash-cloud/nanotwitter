require './models/tweet'
require './models/user'
require './models/tweet_user'
require './models/followee'

class Service 
	def self.login(user_name,password)
		puts 'in login'
		@user=User.find_by(user_name: user_name)
		if @user #if that user exist, check the password
			if @user.password==password
				return 'logged_in'
			else
				return 'wrong password'
			end
		else
			return 'user not found'
		end
	end
	def self.timeline(user_id)
		@user=User.find_by(id: user_id)
		if @user
			return @user.tweets.order(created_at: "DESC")

		else
			return 'user not found'
		end
	end
	def self.followers(user_id)
		users_followed = Follow.where(follower: user_id)
		if users_followed
			return users_followed
		else
			return nil
		end
	end
	def self.get_email_by_id(user_id)
		@user = User.find_by(id: user_id)
		email = @user.email
	end

	def self.register(user_name,password,email)
		email_found = User.find_by(email: email)
		name_found = User.find_by(user_name: user_name)
		if email_found
			return 'email taken'
		elsif name_found
			return 'user_name taken'
		else
			User.create(user_name: user_name,password: password, email: email)
			return 'ok'
		end
	end

	def self.getTweetsByID(tweet_id)
		tweet = Tweet.find_by(id: tweet_id)
		if tweet
			return tweet
		else
			return nil
		end
	end

	def self.getUserByID(user_id)
		user = User.find_by(id: user_id)
		if user
			return user
		else
			return nil
		end
	end

	def self.getRecentTweets()
		tweets = Tweet.all.order(created_at: "DESC").take(100)
		if tweets
			return tweets
		else
			return nil
		end
	end

	def self.post_tweet(tweet_content,user_id)

		@tweet = Tweet.create(text: tweet_content,user_id: user_id)

		return @tweet

	end

	def self.post_tweet_user(user_id,tweet_id)

		@tweet_user = TweetUser.create(tweet_id: tweet_id,user_id: user_id)

		return @tweet_user

	end	

	def self.follow(follower_id, followee_id)
		Follow.create(user_id: followee_id, follower: follower_id)
	end

	def self.unfollow(follower_id, followee_id)
		follow = Follow.where(user_id: followee_id, follower: follower_id)
		Follow.delete(follow)
	end
	def self.get_followers(user_id)

		@followers = Follow.where(user_id: user_id)

		return @followers
	end

	def self.followed?(followee_id,follower_id)
		puts 'followee',followee_id,'follower',follower_id
		followed_record=Follow.where(user_id:followee_id).find_by(follower: follower_id)
		if followed_record
			return true
		else
			return false
		end
	end

	def self.get_stream(user_id)
		tweets = Tweet.where(user_id:user_id).order(created_at: "DESC").take(100)
		return tweets
	end
	
    def self.get_users_to_follow(user_id)
	    #get all the users who aren't you
		@other_users = User.where.not(id: user_id)
		puts("number of other users is #{@other_users.size}")
		#get all the people you follow
		@followees = followers(user_id)
		
		@recommended = []
		
		@other_users.each do |other_user|
		    followed = false
			@followees.each do |followee|
			    #if other_user is a followee of you, followed is true
				if other_user.id == followee.user_id
					followed = true
				end
			end	
			#if you don't follow other_user yet, push to recommended
			if followed == false  
			    @recommended.push(other_user)
			end				
		end
		return @recommended
	end

	
end
