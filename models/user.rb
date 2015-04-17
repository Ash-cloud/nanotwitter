class User < ActiveRecord::Base
    validates_uniqueness_of :user_name, :email
    has_many :follows   
    def to_json
        super(:except => :password)
    end
end
