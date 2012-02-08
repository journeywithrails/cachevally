class SpecialImage < Item
  
  belongs_to :special

  has_attachment :storage => :file_system, 
                 :path_prefix => 'public/system/items',
                 :max_size => 1.megabytes,
                 :thumbnails => { :thumb => '125x125!',
                                  :mini  => '75x75!' },
                 :processor => :MiniMagick # attachment_fu looks in this order: ImageScience, Rmagick, MiniMagick

  validates_as_attachment
  validates_presence_of :filename
  
end