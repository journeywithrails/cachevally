class Special < ActiveRecord::Base

  Special_types = {
    :lunch       => "Lunch",
    :unspecified => nil
  }

  # Relationships
  belongs_to :listing

  has_many :special_images, :as => :resource, :dependent => :destroy

  # Validations
  validates_presence_of     :title
  # validates_numericality_of :cost, :message => "can only contain numbers"
#  validates_file_format_of  :image,        :in => ["gif", "png", "jpg"]
  validates_inclusion_of    :special_type, :in => Special_types.values
  # validates_inclusion_of   :date_expires, :in => Range.new(Date.today, 30.day.from_now.to_date), :message => 'can be no more than 30 days from today'
  validates_presence_of     :date_expires
  validates_date            :date_expires,
                            :after => Date.today,
                            :after_message => 'must be after today',
                            :before => Proc.new { 30.day.from_now.to_date },
                            :before_message => "can be no more than 30 days from today (#{30.days.from_now.strftime("%e %B %Y")} or earlier)"

  # File Column declarations
  file_column :image,
              :magick => {
                :geometry => "600x600",
                :versions => { "thumb" => { :crop => "1:1", :size => "75x75" },
                               "mini"  => { :crop => "1:1", :size => "50x50" }
                }
              }

  def asset_attributes=(asset_attributes)
    asset_attributes.each do |attributes|
      # asset.build(attributes)
      assets.build(attributes)
    end
  end
  
  def is_expired?
    return false if date_expires.blank?
    date_expires < Date::today
  end

  def self.find_unexpired
    find(:all, :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today])
  end

  def self.find_featured_specials_ids
    find(
      :all,
      :select => 'id',
      :conditions => ["(date_expires is ? or date_expires >= ?) and featured > ?", nil, Date::today, 0] )
  end

  def self.find_active_specials(sort_by='business ASC', limit=100)

    find(:all,
         :joins => "as sp join listings as li on sp.listing_id = li.id",
         :select => 'sp.id, sp.title, sp.date_expires, sp.description, sp.price, sp.image, sp.listing_id, sp.created_on, li.business',
         # :select => 'sp.id, sp.title, sp.date_expires, sp.description, sp.cost, sp.image, sp.listing_id, sp.created_on, li.business',
         :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today],
         :limit => limit,
         :order => sort_by )

    # 
    # 
    # 
    # case order
    # when 'price'
    #   sort_by = 'cost DESC'
    # when 'business'
    #   sort_by = 'business ASC'
    # when 'expiry'
    #   sort_by = 'date_expires ASC'
    # else
    #   sort_by = 'business ASC'
    # end
    # 
    # 
    # # Post.find_by_sql "SELECT p.*, c.author FROM posts p, comments c WHERE p.id = c.post_id"
    # 
    # @specials = Special.find(
    #   :all,
    #   # :page       => { :size => 10, :current => 1 },
    #   # :joins      => "specials sp, listings li"
    #   # :select     => 'id, title, date_expires, description'
    #   # :joins      => "as sp join listings as li on sp.listing_id = li.id"
    #   # :select     => "specials.*, listing.business",
    #   # :conditions => ["date_expires is ? or date_expires >= ? and sp.listing_id = li.id", nil, Date::today],
    #   :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today],
    #   # :order      => "listing.business ASC",
    #   :order      => sort_by
    #   # :limit      => 100
    #   )

    # case order
    # when 'price'
    #   sort_by = 'cost DESC'
    # when 'business'
    #   sort_by = 'business ASC'
    # 
    #   # In your contoller, write your queries...
    #   #  1) You need a separate count query for pagination
    #   #    - This query does not have to include all the same tables, use joins only relevant to your results 
    #   #    (same set should be retrieved from the database - avoid tables that provide additional information to 
    #   #     keep the cost of the query down)  
    #   #  2) Write your actual select query 
    # 
    #   # In example below, I dont include table1 in the count query as it is irrelevant for the ordering and size of the retrieved set
    #   count_query = "SELECT count(specials.id) FROM specials ORDER BY specials.created_on DESC"
    #   query       = "SELECT id FROM specials ORDER BY specials.created_on DESC"
    #                 # "FROM specials, listings " +
    #                 # "WHERE listing_id = id " +
    #                 # "ORDER BY specials.listing.business"
    #   # count_query = "SELECT count(widgets.id) from widgets, table2 WHERE ... join conditions ... ORDER BY widgets.created_at DESC"
    #   # query = "SELECT widgets.* from table1, table2, widgets WHERE ... join conditions ... ORDER BY widgets.created_at DESC"
    #   # @widgets = Widget.paginating_sql_find(count_query, query, {:page_size => 10, :current => params[:page]})
    #   @specials = Special.paginating_sql_find(count_query, query,
    #       { :page_size => 10,
    #         :current => current_page } )
    # 
    # when 'expiration'
    #   sort_by = 'date_expires ASC'
    # else
    #   sort_by = 'business ASC'
    # end

    # if paginate
    #   @specials = Special.find(
    #     :all,
    #     :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today],
    #     :order => sort_by,
    #     :limit => 100,
    #     :page => { :size => 10,
    #                :current => current_page || 1,
    #                :first => 1,
    #                :auto => false } )
    # else
    #   @specials = Special.find(
    #     :all,
    #     :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today],
    #     :order => sort_by,
    #     :limit => 50 )
    # end

  end

end
