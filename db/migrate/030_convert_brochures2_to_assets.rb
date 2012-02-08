class ConvertBrochures2ToAssets < ActiveRecord::Migration
  def self.up
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.brochure2_caption, :asset_type => 'BROCHURE')
    #   unless listing.brochure2.nil?
    #     asset.image = File.open(listing.brochure2)
    #     FileUtils.cp(listing.brochure2, asset.image)
    #     asset.save
    #     listing.update_attribute('brochure2', nil)
    #   end
    # end
  end

  def self.down
  end
end
