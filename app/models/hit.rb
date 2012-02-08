class Hit < ActiveRecord::Base

  belongs_to :visitor
  belongs_to :listing
  
end
