class AddListingPaid < ActiveRecord::Migration
  def self.up
    add_column :listings, :paid, :integer, :default => 0
  end

  def self.down
    remove_column :listings, :paid
  end
end
