class ConvertImagesToAssets < ActiveRecord::Migration

  def self.up
    add_column :listings, :max_images, :integer
    
    # Listing.find(:all).each do |listing|
    #   asset1 = Asset.new(:listing_id => listing.id, :caption => listing.image1_caption, :asset_type => 'GENERAL')
    #   unless listing.image1.nil?
    #     asset1.image = File.open(listing.image1)
    #     FileUtils.cp(listing.image1, asset1.image)
    #     asset1.save
    #     listing.update_attribute('image1', nil)
    #   end
    # end

  end

  def self.down
    remove_column :listings, :max_images
    # raise IrreversibleMigration
  end

end
