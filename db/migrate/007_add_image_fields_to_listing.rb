class AddImageFieldsToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :image1, :string
    add_column :listings, :image2, :string
    add_column :listings, :image3, :string
    add_column :listings, :image4, :string
    add_column :listings, :menu1, :string
    add_column :listings, :menu2, :string
  end

  def self.down
    remove_column :listings, :image1
    remove_column :listings, :image2
    remove_column :listings, :image3
    remove_column :listings, :image4
    remove_column :listings, :menu1
    remove_column :listings, :menu2
  end
end
