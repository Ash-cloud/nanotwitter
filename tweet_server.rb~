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
	#Tweet is an array with length 4, this methods are provided to incapsulate the array
	def self.Tweet_user_id(tweet)
		return tweet[0]
	end
	def self.Tweet_user_name(tweet)
		return tweet[1]
	end
	
	def self.Tweet_text(tweet)
		return tweet[2]
	end

	def self.Tweet_create_time(tweet)
		return tweet[3]
	end
	
	
	#split 4 attributes into sperate array
	#We split here because because we don't want require api file in erb
	def self.create_Tweets_attribute_arrays(tweets)
		user_id_array=[]
		user_name_array=[]
		created_time_array=[]
		text_array=[]
		tweets.map{|tweet|
			user_id_array.push Tweet_Service.Tweet_user_id(tweet)
			user_name_array.push Tweet_Service.Tweet_user_name(tweet)
			created_time_array.push Tweet_Service.create_time_interval(Tweet_Service.Tweet_create_time(tweet))
			text_array.push Tweet_Service.Tweet_text(tweet)
		}
		return user_id_array,user_name_array,created_time_array,text_array

	end

	def self.timeline(user_id)
		tweets=Follow.where(follower:user_id).joins("LEFT JOIN tweets ON tweets.user_id = follows.user_id").joins("LEFT JOIN users ON tweets.user_id = users.id").where("tweets.text is NOT NULL").order("tweets.created_at desc").pluck(:user_id,:user_name,:text, "tweets.created_at")
		return tweets
	end

	#using DataHelper to generate the describition of time
	def self.create_time_interval(created_time)
		from_time = Time.now
		distance_of_time_in_words(from_time,created_time) 
	end

	def self.getRecentTweets()
		tweets =Tweet.limit(100).order("tweets.created_at desc").joins("LEFT JOIN users ON tweets.user_id = users.id").pluck(:user_id,:user_name,:text,:created_at)

		if tweets
			return tweets
		else
			return nil
		end
	end



	#problem here:length will never expand even is under 100

	def self.update_redis_for_timeline(tweet,user_id)
		followers=Follow_Service.get_followers(user_id)
		f_list=[]
		followers.each do |follower|
			f_list.push follower.follower
		end
		c_list=JSON.parse($redis.get("cached-users"))
		public_part=f_list&c_list
		public_part.each do  |user|
			puts "updating cache for user_id:#{user}"
			timeline=JSON.parse($redis.get(user))
			timeline=timeline.unshift(tweet)
			if timeline.length>100
				timeline.pop
			end
			$redis.set(user,JSON.generate(timeline))
		end
	end

	def self.update_redis_for_recent_tweet(tweet)
		recent_tweets = JSON.parse($redis.get("100-tweets"))
		recent_tweets=recent_tweets.unshift(tweet)
		recent_tweets.pop
		$redis.set("100-tweets",JSON.generate(recent_tweets))
	end

	def self.post_tweet(tweet_content,user_id)
		puts "user_id is:#{user_id}"
		@tweet = Tweet.create(text: tweet_content,user_id: user_id)
		user_name=User.find_by(id: user_id).user_name
		new_tweet=[user_id,user_name,tweet_content,@tweet.created_at]
		puts new_tweet
		update_redis_for_timeline(new_tweet,user_id)
		update_redis_for_recent_tweet(new_tweet)		
		return @tweet
	end

	def self.get_stream(user_id)
		tweets = Tweet.where(user_id:user_id).limit(100).order('tweets.created_at desc').joins("LEFT JOIN users ON tweets.user_id = users.id").pluck(:user_id,:user_name,:text,:created_at)
		return tweets
	end

end
