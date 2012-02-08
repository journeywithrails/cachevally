class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :parent_id, :integer     # for the thumbnails of resized images, required for attachment_fu plugin
      t.column :type, :string           # for STI on this table (curent types are: Special)
      t.column :resource_type, :string  # for polymorphism on this table (current types are SpecialImage)
      t.column :resource_id, :integer   # for polymorphism, (special_image_id, etc)
      # attachment_fu requirements
      t.column :content_type, :string   # Fields here [content_type] and below all attachment_fu requirements
      t.column :filename, :string
      t.column :thumbnail, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
  end

  def self.down
    remove_table :asset2s
  end
end
