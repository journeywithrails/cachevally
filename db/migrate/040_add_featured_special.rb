class AddFeaturedSpecial < ActiveRecord::Migration
  def self.up
    add_column :specials, :featured, :integer, :default => 0
  end

  def self.down
    remove_column :specials, :featured
  end
end
