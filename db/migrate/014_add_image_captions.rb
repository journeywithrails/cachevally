class AddImageCaptions < ActiveRecord::Migration
  def self.up
    add_column :listings, :image1_caption, :string
    add_column :listings, :image2_caption, :string
    add_column :listings, :image3_caption, :string
    add_column :listings, :image4_caption, :string
    add_column :listings, :menu1_caption, :string
    add_column :listings, :menu2_caption, :string
    add_column :listings, :brochure1_caption, :string
    add_column :listings, :brochure2_caption, :string
  end

  def self.down
    remove_column :listings, :image1_caption
    remove_column :listings, :image2_caption
    remove_column :listings, :image3_caption
    remove_column :listings, :image4_caption
    remove_column :listings, :menu1_caption
    remove_column :listings, :menu2_caption
    remove_column :listings, :brochure1_caption
    remove_column :listings, :brochure2_caption
  end
end
