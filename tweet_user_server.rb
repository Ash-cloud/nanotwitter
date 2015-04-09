require './models/tweet_user'

class TweetUser_Service

	def self.post_tweet_user(user_id,tweet_id)

		@tweet_user = TweetUser.create(tweet_id: tweet_id,user_id: user_id)

		return @tweet_user

	end	


end

