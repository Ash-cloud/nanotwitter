class Follow < ActiveRecord::Base
    validates_uniqueness_of :user_id, :scope => :follower
    belongs_to :users
  
    def to_json
        super()
    end
end
