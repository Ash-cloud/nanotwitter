class Index < ActiveRecord::Migration
    def change
    	add_index(:tweets, :create_at)	    
    end
end
