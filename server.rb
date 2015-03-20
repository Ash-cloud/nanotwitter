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
        tweet = Tweet.find_by(tweet_id: tweet_id)
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

    def self.getRecentTweets(number)
        tweets = Tweet.all.order(created_at: "DESC").take(number)
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
        Follow.create(user_id: followee_id, follower_id: follower_id)
    end
    
    def self.unfollow(follower_id, followee_id)
        follow = Follow.where(user_id: followee_id, follower: follower_id)
        Follow.delete(f)
    end

	def self.get_followers(user_id)

		@followers = Follow.where(user_id: user_id)

		return @followers

	end

	def self.get_stream(user_id)
		 tweets = Tweet.where(user_id:user_id).order(created_at: "DESC").take(100)
		 return tweets
	end

end
