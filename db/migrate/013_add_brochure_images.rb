class AddBrochureImages < ActiveRecord::Migration
  def self.up
    add_column :listings, :brochure1, :string
    add_column :listings, :brochure2, :string
    add_column :listings, :show_brochure, :integer
  end

  def self.down
    remove_column :listings, :brochure1
    remove_column :listings, :brochure2
    remove_column :listings, :show_brochure
  end
end
