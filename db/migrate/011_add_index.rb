class AddIndex < ActiveRecord::Migration
  def change
    #add_index(:follows, :user_id)
    add_index(:tweet_users, :tweet_id)
  end
end
