class CreateFollows < ActiveRecord::Migration
    def self.up
        create_table :follows do |t|
            t.integer :user_id
            t.integer :follower
        end
    end
end
