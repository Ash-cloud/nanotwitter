class Index < ActiveRecord::Migration
    def change
	    add_index(:follows,:user_id)
	    add_index(:follows,:follower)
	    remove_index(:follows,[:user_id,:follower])
	    add_index(:users,:user_name)
	    add_index(:users,:email)
    end
end
