class Tweet < ActiveRecord::Base
    has_many :users, :through => :tweet_users
    has_many :tweet_users, :class_name => 'TweetUser'
    def to_json
        super()
    end
end
