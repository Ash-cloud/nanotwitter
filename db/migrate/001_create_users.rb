class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table :users do |t|
            t.string :password
            t.string :user_name
            t.string :email
            t.integer :user_id
            
            t.timestamps
        end
    end

    def self.down 
        drop_table :users
    end
end
