class ConvertMenus2ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.menu2_caption, :asset_type => 'MENU')
    #   unless listing.menu2.nil?
    #     asset.image = File.open(listing.menu2)
    #     FileUtils.cp(listing.menu2, asset.image)
    #     asset.save
    #     listing.update_attribute('menu2', nil)
    #   end
    # end
  end

  def self.down
  end
end
