class Asset < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true

  belongs_to :listing,
             :class_name  => 'Listing',
             :foreign_key => 'listing_id'

  # belongs_to :special,
  #            :class_name  => 'Special',
  #            :foreign_key => 'special_id'

  # acts_as_list :scope => 'listing_id = \'#{listing_id}\' AND asset_type = \'#{asset_type}\' AND parent_id IS NULL'
  acts_as_list :scope => 'listing_id = \'#{listing_id}\' AND asset_type = \'#{asset_type}\' AND parent_id IS NULL'

  # acts_as_list :scope => 'listing_id = #{listing_id} AND asset_type = \'#{asset_type}\''
  # acts_as_list :scope => 'listing_id = #{listing_id} AND asset_type = \'#{asset_type}\' AND parent_id = NULL'

  Asset_types = {
    :general     => "GENERAL",
    :brochure    => "BROCHURE",
    :menu        => "MENU",
    :special     => "SPECIAL",
    :unspecified => nil
  }

  # Defaults if none specified
  MAX_IMAGES = 12
  MAX_MENUS = 5
  MAX_BROCHURES = 5

  # Attachment_fu support
  has_attachment :storage => :file_system,
                 :path_prefix => 'public/system/assets',
                 :max_size => 1.megabytes,
                 :resize_to => '800x600>',
                 :thumbnails => { :thumb => '125x125!',
                                  :mini  => '75x75!' },
                 :processor => :MiniMagick # attachment_fu looks in this order: ImageScience, Rmagick, MiniMagick
  validates_as_attachment

  # Hook 'image' column to file_column plugin
  file_column :image,
              :magick => {
                :geometry => "800x800",
                :versions => {
                  "thumb" => {:crop => "1:1", :size => "125x125"}
                }
              }
  
  # Validations
  # validates_file_format_of :image,      :in => ["gif", "jpg", "png"]
  # validates_filesize_of    :image,      :in => 5.kilobytes..1.megabyte
  validates_inclusion_of   :asset_type, :in => Asset_types.values

  def self.find_images_for_listing(listing_id, subaction, max_images)
    @listing = Listing.find(listing_id)
    case subaction
    when 'images' || blank?
      img_type = 'GENERAL'
      # max = @listing.max_images ||= MAX_IMAGES
      # max = (@listing.max_images && @listing.max_images > 0) ? @listing.max_images : MAX_IMAGES
    when 'brochure'
      img_type = 'BROCHURE'
      # max = @listing.max_brochures ||= MAX_BROCHURES
      # max = (@listing.max_brocures && @listing.max_brochures > 0) ? @listing.max_brochures : MAX_BROCHURES
    when 'menu'
      img_type = 'MENU'
      # max = (@listing.max_menus && @listing.max_menus > 0) ? @listing.max_menus : MAX_MENUS
    end
    assets = find(
      :all,
      :order => 'position', 
      :conditions => ["listing_id = ? and asset_type = ?", listing_id, img_type],
      :limit => max_images )
  end

  # def self.find_images_for_listing(listing, max_param = MAX_IMAGES)
  #   max = (max_param.nil? or max_param == 0) ? MAX_IMAGES : max_param
  #   # max = max_param ||= MAX_IMAGES
  #   assets = find(
  #     :all,
  #     :conditions => ["listing_id = ? and asset_type = ?", listing.id, 'GENERAL'],
  #     :order => 'position',
  #     :limit => max)
  # end
  # 
  # def self.find_brochures_for_listing(listing, max_param = MAX_BROCHURES)
  #   # max = max_param ||= MAX_BROCHURES
  #   # MySQL defaults to "0", but we want "0" to indicate "no specific limit"
  #   max = (max_param.nil? or max_param == 0) ? MAX_BROCHURES : max_param
  #   assets = find(
  #     :all,
  #     :conditions => ["listing_id = ? and asset_type = ?", listing.id, 'BROCHURE'],
  #     :order => 'position',
  #     :limit => max)
  # end
  # 
  # def self.find_menus_for_listing(listing, max_param = MAX_MENUS)
  #   # max = max_param ||= MAX_MENUS
  #   max = (max_param.nil? or max_param == 0) ? MAX_MENUS : max_param
  #   assets = find(
  #     :all,
  #     :conditions => ["listing_id = ? and asset_type = ?", listing.id, 'MENU'],
  #     :order => 'position',
  #     :limit => max)
  # end

  def short_filename(f)
    begin
      return f[/\/[\w\-]+.[a-z]{3}$/].delete("/")
    rescue
      return f
    end
  end

end
