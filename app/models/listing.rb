class Listing < ActiveRecord::Base

  acts_as_rateable

  # Relationships
  belongs_to :user
  has_many :assets,
           :class_name => 'Asset',
           :foreign_key => 'listing_id',
           :order => 'position'

  has_many :hits
  has_many :specials
  has_one  :closure
  has_many :comments

  has_many :hits_today,
           :class_name => 'Hit',
           :foreign_key => 'listing_id',
           :conditions => [ "created_at >= ?", Date.today() ]

  has_many :hits_week,
           :class_name => 'Hit',
           :foreign_key => 'listing_id',
           :conditions => [ "created_at >= ?", 1.weeks.ago]

  has_many :hits_month,
           :class_name => 'Hit',
           :foreign_key => 'listing_id',
           :conditions => [ "created_at >= ?", 1.months.ago]

  # Validation
  validates_presence_of    :business
  # validates_uniqueness_of  :business
  validates_acceptance_of  :terms_of_agreement, :on => :create,
                           :message => "- please accept the terms to proceed"
  validates_file_format_of :image,     :in => ["gif", "png", "jpg"]
  validates_file_format_of :menu1,     :in => ["gif", "png", "jpg", "pdf"]
  validates_file_format_of :menu2,     :in => ["gif", "png", "jpg", "pdf"]
  validates_file_format_of :image1,    :in => ["gif", "png", "jpg"]
  validates_file_format_of :image2,    :in => ["gif", "png", "jpg"]
  validates_file_format_of :image3,    :in => ["gif", "png", "jpg"]
  validates_file_format_of :image4,    :in => ["gif", "png", "jpg"]
  validates_file_format_of :brochure1, :in => ["gif", "png", "jpg", "pdf"]
  validates_file_format_of :brochure2, :in => ["gif", "png", "jpg", "pdf"]
  validates_presence_of    :date_paid_expires
  validates_presence_of    :date_paid_start

  file_column :image,     :magick => { :geometry => "175x175", :versions => {"thumb" => "75x75",   "mini_thumb" => "50x50"} }
  file_column :menu1,     :magick => { :geometry => "800x640", :versions => {"thumb" => "200x200", "mini_thumb" => "50x50"} }
  file_column :menu2,     :magick => { :geometry => "800x640", :versions => {"thumb" => "200x200", "mini_thumb" => "50x50"} }
  file_column :image1,    :magick => { :geometry => "600x600", :versions => {"thumb" => "150x150", "mini_thumb" => "50x50"} }
  file_column :image2,    :magick => { :geometry => "600x600", :versions => {"thumb" => "150x150", "mini_thumb" => "50x50"} }
  file_column :image3,    :magick => { :geometry => "600x600", :versions => {"thumb" => "150x150", "mini_thumb" => "50x50"} }
  file_column :image4,    :magick => { :geometry => "600x600", :versions => {"thumb" => "150x150", "mini_thumb" => "50x50"} }
  file_column :brochure1, :magick => { :geometry => "800x640", :versions => {"thumb" => "200x200", "mini_thumb" => "50x50"} }
  file_column :brochure2, :magick => { :geometry => "800x640", :versions => {"thumb" => "200x200", "mini_thumb" => "50x50"} }

  def short_filename(f)
    begin
#      return f[/\/\w*.\w*$/].delete("/")
#      return f[/\/[\w-]*.(gif|png|jpg)$/].delete("/")
      return f[/\/[\w\-]+.[a-z]{3}$/].delete("/")
    rescue
      return f
    end
  end

  def format_phone(number)
    # Remove all non-numeric characters
    begin
      number = number.gsub(/[^0-9]/, '')
      return '(' << number[0..2] << ') ' << number[3..5] << '-' << number[6..9]
    rescue
      return ''
    end
  end

  def is_paid?
    @today = Date.today
    if self.date_paid_start == nil or self.date_paid_expires == nil then
      return false
    elsif self.date_paid_start <= @today and self.date_paid_expires > @today
      return true
    elsif self.date_paid_start > @today
      return false #unpaid - future
    elsif self.date_paid_expires < @today
      return false #unpaid - expired
    else
      return false
    end
  rescue
    return false
  end

  def is_deluxe?
    return self.show_deluxe > 0
  end

  def has_category
    if self.category != nil and
       self.category != '' and
       self.category > 0
      return true
    else
      return false
    end
  end

  def category_name
    category.name
  end
  
  def category_name=(name)
    self.category = Category.find_by_name(name)
  end

  def is_unclaimed?
    if self.user_id == nil or self.user_id == 0
      return true
    else
      return false
    end
    # self.user_id.blank? ? return true : return false
  end

  def record_visitor_and_listing_hit(ip = '', url = '')
    # Record visitor
    # ip = request.remote_ip
    @visitor = Visitor.create_if_new_today(ip)
    @visitor.ip = ip
    if user_logged_in? and !self.is_owner? and !is_admin and @visitor.save
      # Record page hit
      # url = request.request_uri
      hit = Hit.new
      hit.url = url
      hit.visitor = @visitor
      # hit.controller = controller
      # hit.action = action
      # hit.subaction = subaction
      hit.controller = params[:controller]
      hit.action = params[:action]
      hit.subaction = params[:subaction] ||= ''
      self.hits << hit
    end
  end

  def is_owner?
    @user = User.find(session[:user])
    if @user and @user.id == id?
      return true
    else
      return false
    end
  end

  # @listings_recently_added = Listing.recently_added
  # @listings_recently_updated = Listing.recently_updated
  # @listings_recently_reviews = Listing.recently_reviewed

  def self.find_recently_added(age=3.days.ago)
    conditions = ["created_on >= ?", age]
    find(:all, :conditions => conditions)
  end

  def self.find_recently_updated
    conditions = ["updated_on >= ? and created_on < ?", 3.days.ago, 3.days.ago]
    find(:all, :conditions => conditions)
  end

  def self.find_featured(limit=10)
    find( :all,
          :conditions => ['featured = ?', true],
          :limit => limit )
  end
    
end
