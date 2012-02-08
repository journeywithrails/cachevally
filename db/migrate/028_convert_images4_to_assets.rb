class ConvertImages4ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.image4_caption, :asset_type => 'GENERAL')
    #   unless listing.image4.nil?
    #     asset.image = File.open(listing.image4)
    #     FileUtils.cp(listing.image4, asset.image)
    #     asset.save
    #     listing.update_attribute('image4', nil)
    #   end
    # end
  end

  def self.down
  end
end
