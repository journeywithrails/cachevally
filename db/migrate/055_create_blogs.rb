class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :title,          :string
      t.column :abstract,       :string
      t.column :body,           :text
      t.column :date_published, :datetime
      t.column :created_at,     :datetime,  :null => false  
      t.column :updated_at,     :datetime,  :null => false  
    end
  end

  def self.down
    drop_table :blogs
  end
end
