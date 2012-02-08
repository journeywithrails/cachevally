class ParseListingImportZipcode < ActiveRecord::Migration

  def self.up
    add_column :listing_imports, :zip, :string
    ListingImport.find(:all).each do |listing|
      begin
        addr = listing.address.strip
        zip = addr.slice(/\s+\d+$/).strip
        new_addr = addr.gsub(/\s+\d+$/, '')
        puts zip
        listing.update_attribute('address', new_addr)
        listing.update_attribute('zip', zip)
      rescue Exception => e
      end
    end
  end

  def self.down
    remove_column :listing_imports, :zip
  end
end
