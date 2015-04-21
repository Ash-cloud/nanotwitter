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

	def self.post_tweet(tweet_content,user_id)
		@tweet = Tweet.create(text: tweet_content,user_id: user_id)
		
		#need to update redis when a new tweet is created
		redis_pack = JSON.parse($redis.get("100-tweets"))
		new_id_array = [user_id]
		#prev_id_array = JSON.parse($redis.get("ids"))
		prev_id_array = redis_pack["ids"]
		new_id_array = new_id_array + prev_id_array[0..98] #add most recent 99 tweet ids with newest tweet id at front
		#$redis.set("ids",JSON.generate(new_id_array)) #now put newest most recent 100 tweet ids into redis
		redis_pack["ids"] = new_id_array
		
		new_text_array = [tweet_content]
		#prev_text_array = JSON.parse($redis.get("texts"))
		prev_text_array = redis_pack["texts"]
		new_text_array = new_text_array + prev_text_array[0..98]
		#$redis.set("texts",JSON.generate(new_text_array))
		redis_pack["texts"] = new_text_array
		
		new_name_array = [User.find_by(id: user_id).user_name]
		#prev_name_array = JSON.parse($redis.get("names"))
		prev_name_array = redis_pack["names"]
		new_name_array = new_name_array + prev_name_array[0..98]
		#$redis.set("names",JSON.generate(new_name_array))
		redis_pack["names"] = new_name_array
		

		new_time_array = [create_time_interval(@tweet.created_at)]

		#prev_time_array = JSON.parse($redis.get("times"))
		prev_time_array = redis_pack["times"]
		new_time_array = new_time_array + prev_time_array[0..98]
		#$redis.set("times",JSON.generate(new_time_array))
		redis_pack["times"] = new_time_array
		
		$redis.set("100-tweets",JSON.generate(redis_pack))		
		return @tweet
	end

	def self.get_stream(user_id)
		tweets = Tweet.where(user_id:user_id).limit(100).order('tweets.created_at desc').joins("LEFT JOIN users ON tweets.user_id = users.id").pluck(:user_id,:user_name,:text,:created_at)
		return tweets
	end

end
