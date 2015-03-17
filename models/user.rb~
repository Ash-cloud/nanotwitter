class User < ActiveRecord::Base
    validates_uniqueness_of :user_name, :email
    has_many :tweet_users, :class_name => 'TweetUser'
    has_many :tweets, :through => :tweet_users
    has_many :follows   
    def to_json
        super(:except => :password)
    end
end
