class Index < ActiveRecord::Migration
    def change
    	remove_index(:users, :id)	    
    end
end
