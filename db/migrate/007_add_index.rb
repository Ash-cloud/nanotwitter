class AddIndex < ActiveRecord::Migration
  def change
    add_index(:follows, :user_id)
  end
end
