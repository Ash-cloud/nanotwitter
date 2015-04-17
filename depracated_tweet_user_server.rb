require './models/tweet_user'
require_relative 'tweet_server.rb'

class TweetUser_Service

	def self.post_tweet_user(user_id,tweet_id, creator_id)

		@tweet_user = TweetUser.create(tweet_id: tweet_id,user_id: user_id, creator_id: creator_id)

		return @tweet_user

	end	
	
	def self.add_old_tweets(follower_id,followee_id)
	    followees_tweets = Tweet_Service.get_stream(followee_id) #gives 100 tweets 
	    followees_tweets.each do |tweet|
	        post_tweet_user(follower_id, tweet.id, followee_id)
	    end
	end
	
	def self.delete_old_tweets(follower_id,unfollowing_id)
	    TweetUser.where(creator_id: unfollowing_id, user_id: follower_id).delete_all
	end
	


end

