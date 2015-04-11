class Index < ActiveRecord::Migration
    def change
    	add_index(:tweets, :usre_id)	    
    end
end
