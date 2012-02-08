class AddAttachmentFuToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :parent_id, :integer     # for the thumbnails of resized images, required for attachment_fu plugin
    add_column :assets, :content_type, :string   # Fields here [content_type] and below all attachment_fu requirements
    add_column :assets, :filename, :string
    add_column :assets, :thumbnail, :string
    add_column :assets, :size, :integer
    add_column :assets, :width, :integer
    add_column :assets, :height, :integer
  end

  def self.down
    remove_column :assets, :parent_id
    remove_column :assets, :content_type
    remove_column :assets, :filename
    remove_column :assets, :thumbnail
    remove_column :assets, :size
    remove_column :assets, :width
    remove_column :assets, :height
  end
end
