class TweetUser  < ActiveRecord::Base
	validates_uniqueness_of :user_id, :scope => :tweet_id
	belongs_to :tweet
	belongs_to :user
end
