class Item < ActiveRecord::Base

  # Setup as the de facto acts_as_attachment model

  belongs_to :resource, :polymorphic => true

  has_attachment :storage => :file_system, 
                 :path_prefix => 'public/system/items',
                 :max_size => 2.megabytes,
                 :thumbnails => { :thumb  => '125x125!',
                                  :mini   => '75x75!',
                                  :medium => '640x480>' },
                 :processor => :MiniMagick # attachment_fu looks in this order: ImageScience, Rmagick, MiniMagick

  validates_as_attachment
  validates_presence_of :filename

  # Checks that the object is one of the following types before running validation on it
  # def self.is_valid_file?(fileObj)
  #   if fileObj.is_a?(Tempfile)|| fileObj.is_a?(StringIO)
  #      || (defined?(ActionController::TestUploadedFile) && fileObj.instance_of?(ActionController::TestUploadedFile))
  #      true
  #   else
  #      false
  #   end
  # end

end