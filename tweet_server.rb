require './models/tweet'
require 'action_view'

include ActionView::Helpers::DateHelper
class Tweet_Service

	def self.getTweetsByID(tweet_id)
		tweet = Tweet.find_by(id: tweet_id)
		if tweet
			return tweet
		else
			return nil
		end
	end
	#Tweet is an array with length 3, this methods are provided to incapsulate the array
	def self.Tweet_user_name(tweet)
		return tweet[0]
	end
	
	def self.Tweet_text(tweet)
		return tweet[1]
	end

	def self.Tweet_create_time(tweet)
		return tweet[2]
	end

	#using DataHelper to generate the describition of time
	def self.create_time_interval(created_time)
		from_time = Time.now
		distance_of_time_in_words(from_time,created_time) 
	end

	def self.getRecentTweets()
		tweets =Tweet.limit(100).order("tweets.created_at desc").joins("LEFT JOIN users ON tweets.user_id = users.id").pluck(:user_name,:text,:created_at)

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
