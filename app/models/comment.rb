class Comment < ActiveRecord::Base

  belongs_to :listing
  belongs_to :user

  def self.find_recently_added
    conditions = ['created_at >= ?', 3.days.ago]
    find(:all, :conditions => conditions)
  end

end
