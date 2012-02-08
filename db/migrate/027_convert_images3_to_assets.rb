class ConvertImages3ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.image3_caption, :asset_type => 'GENERAL')
    #   unless listing.image3.nil?
    #     asset.image = File.open(listing.image3)
    #     FileUtils.cp(listing.image3, asset.image)
    #     asset.save
    #     listing.update_attribute('image3', nil)
    #   end
    # end
  end

  def self.down
  end
end
