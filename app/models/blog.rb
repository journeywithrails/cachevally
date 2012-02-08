class Blog < ActiveRecord::Base

  # has_many :items, :as => :resource # attachments to blog item (ie. images)

  validates_presence_of :title, :body
  
  acts_as_textiled  :body

end
