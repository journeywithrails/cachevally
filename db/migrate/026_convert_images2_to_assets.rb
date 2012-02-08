class ConvertImages2ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.image2_caption, :asset_type => 'GENERAL')
    #   unless listing.image2.nil?
    #     asset.image = File.open(listing.image2)
    #     FileUtils.cp(listing.image2, asset.image)
    #     asset.save
    #     listing.update_attribute('image2', nil)
    #   end
    # end
  end

  def self.down
  end
end
