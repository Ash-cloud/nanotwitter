class CreateTimelines < ActiveRecord::Migration
    def self.up
	    create_table :tweet_users do |t|
            t.belongs_to :user, index: true
            t.belongs_to :tweet, index:true
        end
    end
end
