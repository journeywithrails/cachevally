class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|  
      t.column :user_id,     :integer,  :default => 0,  :null => false
      t.column :listing_id,  :integer,  :default => 0,  :null => false
      t.column :body,        :text
      t.column :created_at,  :datetime,                 :null => false  
    end  
  end

  def self.down
    drop_table :comments
  end
end
