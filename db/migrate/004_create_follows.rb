class CreateFollows < ActiveRecord::Migration
    def self.up
        create_table :follower_followees do |t|
            t.integer :follower
            t.integer :followee
        end
    end
end
