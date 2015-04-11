require './models/tweet'

class Tweet_Service

	def self.getTweetsByID(tweet_id)
		tweet = Tweet.find_by(id: tweet_id)
		if tweet
			return tweet
		else
			return nil
		end
	end

	def self.getRecentTweets()
		#tweets = Tweet.all.order(created_at: "DESC").take(100)
		tweets = Tweet.limit(20).order('created_at desc')
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

	def self.get_stream(user_id)
		#tweets = Tweet.where(user_id:user_id).order(created_at: "DESC").take(100)
		tweets = Tweet.where(user_id:user_id).limit(20).order('created_at desc')
		return tweets
	end

end
