class Index < ActiveRecord::Migration
    def change
    	remove_index(:tweets, :created_at)
	add_index(:follows,[:user_id,:follower])	
    end
end
