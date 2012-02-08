class AddAssetPosition < ActiveRecord::Migration
  def self.up
    add_column :assets, :position, :integer

    # Set default list orders
    # Listing.find(:all).each do |l|
    #   ['GENERAL', 'BROCHURE', 'MENU'].each do |img_type|
    #     Asset.find(:all, :conditions => ['listing_id = ? and asset_type = ?', l.id, img_type]).inject(1) do |i, p|
    #       p.update_attribute(:position, i)
    #       i+1
    #     end
    #   end
    # end
  end

  def self.down
    remove_column :assets, :position
  end
end
