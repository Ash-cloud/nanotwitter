class Index < ActiveRecord::Migration
    def change
	    add_index(:follows,:user_id)
	    add_index(:follows,:follower)
	    add_index(:users,:user_name)
	    add_index(:users,:email)
	    add_index(:tweets,:created_at)
	    add_index(:tweets,:user_id)
    end
end
