class Category < ActiveRecord::Base

  # Relationships
  has_many :listings

end
