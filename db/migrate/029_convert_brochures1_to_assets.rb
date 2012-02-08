class ConvertBrochures1ToAssets < ActiveRecord::Migration

  def self.up 
    add_column :listings, :max_brochures, :integer
    
    # Listing.find(:all).each do |listing|
    #   asset = Asset.new(:listing_id => listing.id, :caption => listing.brochure1_caption, :asset_type => 'BROCHURE')
    #   unless listing.brochure1.nil?
    #     asset.image = File.open(listing.brochure1)
    #     FileUtils.cp(listing.brochure1, asset.image)
    #     asset.save
    #     listing.update_attribute('brochure1', nil)
    #   end
    # end
  end

  def self.down
    remove_column :listings, :max_brochures
  end

end
