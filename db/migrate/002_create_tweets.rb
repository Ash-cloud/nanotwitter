class CreateTweets < ActiveRecord::Migration
    def self.up
        create_table :tweets do |t|
            t.string :text
            t.integer :user_id
            
            t.timestamps
        end
        
        def self.down
            drop_table :tweets
        end
    end
end
