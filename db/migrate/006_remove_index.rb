class RemoveIndex < ActiveRecord::Migration
  def change
    remove_index(:tweet_users, :tweet_id)
  end
end
