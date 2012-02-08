class ConvertMenus1ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.menu1_caption, :asset_type => 'MENU')
    #   unless listing.menu1.nil?
    #     asset.image = File.open(listing.menu1)
    #     FileUtils.cp(listing.menu1, asset.image)
    #     asset.save
    #     listing.update_attribute('menu1', nil)
    #   end
    # end
    add_column :listings, :max_menus, :integer
  end

  def self.down
    remove_column :listings, :max_menus
  end
end
