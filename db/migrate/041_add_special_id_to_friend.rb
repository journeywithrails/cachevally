class AddSpecialIdToFriend < ActiveRecord::Migration
  def self.up
    add_column :friends, :special_id, :integer
  end

  def self.down
    remove_column :friends, :special_id
  end
end
