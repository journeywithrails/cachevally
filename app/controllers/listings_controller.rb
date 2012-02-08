class ListingsController < ApplicationController

  before_filter :check_admin_authentication, :only => {'home2', 'home_old'}


  require "ym4r/yahoo_maps/building_block/traffic"
  include Ym4r::YahooMaps::BuildingBlock

  require 'gruff' 
  # require 'ruby-debug'

  before_filter :check_authentication, :only => ['edit', 'new', 'claim_this_listing', 'stats']

  layout 'default', :except => :email_business

  in_place_edit_for :asset, :caption

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post,
         :only => [ :destroy, :destroy_file, :update ],
         :redirect_to => { :action => :index }
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def home_old
    @homepage = true
    @listings_recently_added = Listing.find_recently_added
    @listings_recently_updated = Listing.find_recently_updated
    @reviews_recent = Comment.find_recently_added
    list_of_specials = (Special.find_featured_specials_ids).map{|s| s.id} # create array of ids of all featured specials
    begin
      @special = Special.find( list_of_specials[rand(list_of_specials.size)] ) # randomly choose one of the active ids, and get that special
      @has_image = !(@special.image.nil? or @special.image == '')
    rescue
    end
  end

  def list
    @specials = Special.find_active_specials('date_expires ASC', 3)
    @featured_listings = Listing.find_featured(3)
    @reviews = Comment.find_recently_added
    @new_listings = Listing.find_recently_added(2.weeks.ago)
    @col1_categories = %w[Automotive Bakeries Beauty\ Salons Construction Dentists Entertainment Hospitals]
    @col2_categories = %w[Newspaper Orthodontics Restaurants Real\ Estate Physicians]
    @col3_categories = %w[Sporting\ Goods Telecommunications Utilities Vending Website\ Design]
    @blogs = Blog.find(:all, :order => 'date_published DESC', :limit => 3)
    list_of_specials = (Special.find_featured_specials_ids).map{|s| s.id} # create array of ids of all featured specials
    begin
      @special = Special.find( list_of_specials[rand(list_of_specials.size)] ) # randomly choose one of the active ids, and get that special
      @has_image = !(@special.image.nil? or @special.image == '')
    rescue
    end
  end

  def home2
    @specials = Special.find_active_specials('date_expires ASC', 3)
    @featured_listings = Listing.find_featured(3)
    @reviews = Comment.find_recently_added
    @new_listings = Listing.find_recently_added(2.weeks.ago)
    @col1_categories = %w[Automotive Bakeries Beauty\ Salons Carpenters Dentists Entertainment Hospitals Jewelery]
    @col2_categories = %w[Newspaper Orthodontics Restaurants Real\ Estate Physicians]
    @col3_categories = %w[Sporting\ Goods Telecommunications Utilities Vending Website\ Design]
    @blogs = Blog.find(:all, :order => 'date_published DESC', :limit => 3)
    list_of_specials = (Special.find_featured_specials_ids).map{|s| s.id} # create array of ids of all featured specials
    begin
      @special = Special.find( list_of_specials[rand(list_of_specials.size)] ) # randomly choose one of the active ids, and get that special
      @has_image = !(@special.image.nil? or @special.image == '')
    rescue
    end
  end

  def live_search
    # @phrase = request.raw_post || request.query_string
    @phrase = params[:phrase]
    @trim_phrase = ''
    @trim_phrase = @phrase.gsub(/^\s+/, "").gsub(/\s+$/, $/) unless @phrase.blank?
    if @trim_phrase == nil or @trim_phrase == '' or @trim_phrase.size < 3
      @number_match = 0
      @results = nil
    else
      # a1 = "%"
      # a2 = "%"
      # @searchphrase = a1 + @phrase + a2
      @searchphrase = "%" + @phrase + "%"
      # non-expired paid listings should display first in search results
      @order = "( (date_paid_expires > 0) AND (to_days(date_paid_expires) - to_days(now()) > 0) AND
                  (date_paid_start > 0) AND (to_days(now()) - to_days(date_paid_start)) >= 0
                ) DESC,
                business ASC"

      @results = Listing.find( :all,
                               :conditions => ["active = '1' AND (business LIKE ? OR keywords LIKE ?)", @searchphrase, @searchphrase],
                               :limit => 20,
                               :order => @order )
      @number_match = @results.length

    end
    render(:layout => false)
  end

  def search
    # if ENV['RAILS_ENV'] != 'development' and !request.post?
    list_of_specials = (Special.find_featured_specials_ids).map{|s| s.id} # create array of ids of all featured specials
    begin
      @special = Special.find( list_of_specials[rand(list_of_specials.size)] ) # randomly choose one of the active ids, and get that special
      @has_image = !(@special.image.nil? or @special.image == '')
    rescue
    end
    query = params[:query] ||= params[:q]
    if query.nil?
      redirect_to :action => 'list'
    else
      @phrase = CGI.escapeHTML(query)
      # @phrase = CGI.escapeHTML(params[:query] ||= params[:q] ||= '')
      @trim_phrase = @phrase.gsub(/^\s+/, "").gsub(/\s+$/, $/)
      if @trim_phrase == nil or @trim_phrase == '' or @trim_phrase.size < 3
        @number_match = 0
        @results = nil
      else
        @searchphrase = "%" + @phrase + "%"
        @order = "( (date_paid_expires > 0) AND (to_days(date_paid_expires) - to_days(now()) > 0) AND
                    (date_paid_start > 0) AND (to_days(now()) - to_days(date_paid_start)) >= 0
                  ) DESC,"
        if params[:sort] == 'city'
          @order << ' city ASC'
        else
          @order << ' business ASC'
        end
        @results = Listing.find(
          :all,
          :conditions => ["active = '1' AND (business LIKE ? OR keywords LIKE ?)", @searchphrase, @searchphrase],
          :order => @order )
        @number_match = @results.length
      end
    # redirect_to :action => 'search'
    end 
  end

  def list_by_city_old
    # URL format = /listings/list_by_city/<city>/<letter>
    # eg. /listings/list_by_city/hyrum/a
    #     returns all businesses in Hyrum that start with "a"
    @cities = City.find :all, :order => 'name'

    @conditions = "active = '1'"
    @city = params[:city] ||= ''
    if params[:city] != ''
      @conditions << " AND city like '" << params[:city] << "'"
    end
    
    if (params[:letter] != '') and (params[:letter] != nil)
      @conditions << " AND business like '" << params[:letter] << "%'"
    end

    @listing_total = Listing.find :all, :conditions => @conditions
    @listing_pages, @listings = paginate :listings,
                                         :per_page => 25,
                                         :first_n => 1000,
                                         :conditions => @conditions,
                                         :order => "business ASC"
  end

  def list_by_city
    list_of_specials = (Special.find_featured_specials_ids).map{|s| s.id} # create array of ids of all featured specials
    begin
      @special = Special.find( list_of_specials[rand(list_of_specials.size)] ) # randomly choose one of the active ids, and get that special
      @has_image = !(@special.image.nil? or @special.image == '')
    rescue
    end
    @page_title = "Browse By City"
    @cities = City.find(:all, :order => 'name')
    @conditions = "active = '1'"
    if params[:city] and params[:city] != 'all'
    # if params[:city] and params[:city] != ''
      @conditions << " AND city like '" << params[:city] << "'" # unless !params[:city]
    end
    if params[:letter] and params[:letter] != ''
      @conditions << " AND business like '" << params[:letter] << "%'" # unless !params[:letter]
    end

    @listings = Listing.find( :all,
                              :conditions => @conditions,
                              :order => "business ASC",
                              :limit => 500,
                              :page => { :size => 25,
                                         :first => 1,
                                         :current => params[:page] || 1,
                                         :auto => false } )

    # set subtitle for <h1> element in view
    if params[:city] and params[:city] != '' 
      @subtitle = '| ' << params[:city] << ' (' << @listings.size.to_s  << ')'
    else
      @subtitle = '| All'
    end
  end

  def goto_city
    if params[:city] then
      redirect_to_url "/listings/list_by_city/#{params[:city]}"
    else
      redirect_back_or_default
      # redirect_to :back
    end
  end

  def is_owner?(id)
    unless user_logged_in?
      return false
    end
    @user = User.find(session[:user])
    @listing = Listing.find(id)
    if @user and @listing.user_id == @user.id and @listing.editor_approved?
      return true
    else
      return false
    end
  end

  def record_visitor_and_listing_hit(listing_id, selected)
    # Record visitor
    ip = request.remote_ip
    @visitor = Visitor.create_if_new_today(ip)
    @visitor.ip = ip
    @visitor.save
    
    # debugger if ENV['RAILS_ENV'] == 'development'
    # 
    # if @visitor
    #   # visitor created
    # end
    # 
    # if !is_owner?(listing_id)
    #   # not owner
    # end
    # 
    # if !user_logged_in? or !is_admin?
    #   # not admin
    # end
    # debugger if ENV['RAILS_ENV'] == 'development'
    
    if @visitor and !is_owner?(listing_id) and (!user_logged_in? or !is_admin?)
      # Record page hit
      url = request.request_uri
      hit = Hit.new
      hit.url = url
      hit.visitor = @visitor

      # hit.controller = controller
      # hit.action = action
      # hit.subaction = subaction
      hit.controller = params[:controller]
      hit.action = params[:action]
      hit.subaction = selected
      # hit.subaction = params[:subaction] ||= 'about'

      @listing = Listing.find(listing_id)
      @listing.hits << hit
    end
  end

  def show
    @listing = Listing.find(params[:id])
    @business_title = @listing.business
    if @listing.approver_id then
      @approver = User.find(@listing.approver_id)
    end
    if user_logged_in?
      @user = User.find(session[:user])
    end

    if params[:subaction].blank?
      if @listing.is_unclaimed?
        @selected = 'welcome'
      elsif @listing.show_about?
        @selected = 'about'
      elsif @listing.show_services?
        @selected = 'services'
      elsif @listing.show_hours?
        @selected = 'hours'
      elsif @listing.show_menu?
        @selected = 'menu'
      elsif @listing.show_brochure?
        @selected = 'brochure'
      elsif @listing.show_images?
        @selected = 'images'
      elsif @listing.show_specials?
        @selected = 'specials'
      elsif @listing.show_map?
        @selected = 'map'
      # elsif @listing.show_reviews?
        # @selected = 'reviews'
      else
        @selected = ''
      end      
    else
      @selected = params[:subaction]
    end

    # Record visit, specify default tab if not specified
    record_visitor_and_listing_hit(@listing.id, @selected)

    case @selected
    when 'welcome'
      # do nothing
    when 'images', 'brochure', 'menu'
      case @selected
      when 'images'
        @max_images = (@listing.max_images && @listing.max_images > 0) ? @listing.max_images : Asset::MAX_IMAGES
      when 'brochure'
        @max_images = (@listing.max_brochures && @listing.max_brochures > 0) ? @listing.max_brochures : Asset::MAX_BROCHURES
      when 'menu'
        @max_images = (@listing.max_menus && @listing.max_menus > 0) ? @listing.max_menus : Asset::MAX_MENUS
      end
      # @images = Asset.find_images_for_listing(@listing.id, params[:subaction], @max_images)
      @images = Asset.find_images_for_listing(@listing.id, @selected, @max_images)

    # when 'images'
    #   @max_images = (@listing.max_images && @listing.max_images > 0) ? @listing.max_images : Asset::MAX_IMAGES
    #   @images = Asset.find_images_for_listing(@listing, @max_images)
    #   # @max_images = (@listing.max_images.nil? or @listing.max_images == 0) ? Asset::MAX_IMAGES : @listing.max_images
    # when 'brochure'
    #   # @max_images = @listing.max_brochures ||= Asset::MAX_BROCHURES
    #   @max_images = (@listing.max_brochures && @listing.max_brochures > 0) ? @listing.max_brochures : Asset::MAX_BROCHURES
    #   @images = Asset.find_images_for_listing(@listing, @max_images)
    #   # @images = Asset.find_brochures_for_listing(@listing, @max_images)
    #   # @max_images = (@listing.max_brochures.nil? or @listing.max_brochures == 0) ? Asset::MAX_BROCHURES : @listing.max_brochures
    # when 'menu'
    #   # @max_images = @listing.max_menus ||= Asset::MAX_MENUS
    #   @max_images = (@listing.max_menus && @listing.max_menus > 0) ? @listing.max_menus : Asset::MAX_MENUS
    #   @images = Asset.find_images_for_listing(@listing, @max_images)
    #   # @images = Asset.find_menus_for_listing(@listing, @max_images)
    #   # @max_images = (@listing.max_menus.nil? or @listing.max_menus == 0) ? Asset::MAX_MENUS : @listing.max_menus
    when 'specials'
      if is_owner_or_admin?(@listing)
        @specials = @listing.specials
      else
        @specials = @listing.specials.find_unexpired
      end
      @special = Special.new
      @special.date_expires = 30.days.from_now
      @special.listing_id = @listing.id
    when 'map'
    # if @selected == 'map' # or params[:subaction] == 'map'
      # User Settings
      @zoom_level = 15
      @map_type = 'hybrid' # ['standard', 'satellite', 'hybrid']
      
      # Create address string for Geocoding
      @addr = ''
      (@addr << @listing.address + ', ') unless @listing.address.blank?
      (@addr << @listing.address2 + ', ') unless @listing.address2.blank?
      (@addr << @listing.city + ', ') unless @listing.city.blank?
      (@addr << @listing.state + ', ') unless @listing.state.blank?
      (@addr << @listing.zip) unless @listing.zip.blank?
      begin
        results = Geocoding::get(@addr)
        if results.status == Geocoding::GEO_SUCCESS
          @map = GMap.new("map_div")
          case @map_type
          when 'standard'
            @map.set_map_type_init(GMapType::G_NORMAL_MAP)
          when 'satellite'
            @map.set_map_type_init(GMapType::G_SATELLITE_MAP)
          when 'hybrid'
            @map.set_map_type_init(GMapType::G_HYBRID_MAP)
          end
          @map.control_init(:large_map => true, :map_type => true)
          coord = results[0].latlon
          @info_label = '<strong>' + @listing.business + '</strong><br/>'
          @info_label << (@listing.address + '<br/>') unless @listing.address.blank?
          @info_label << (@listing.address2 + '<br/>') unless @listing.address2.blank?
          @info_label << (@listing.city + ', ') unless @listing.city.blank?
          @info_label << (@listing.state + '  ') unless @listing.state.blank?
          @info_label << (@listing.zip) unless @listing.zip.blank?
          @info_label << '<br/>'
          @info_label << ('Phone: ' + @listing.phone + '<br/>') unless @listing.phone.blank?
          @info_label << ('Fax: ' + @listing.fax + '<br/>') unless @listing.fax.blank?
          @map.overlay_init(
            GMarker.new(coord, :info_window => @info_label, :title => @listing.business)
          )
          @map.center_zoom_init(coord, @zoom_level)
        else
          flash[:notice] = 'Sorry, a map could not be generated for this address.'
        end    
      rescue
        flash[:notice] = 'Sorry, the mapping service is temporarily unavailable.'
      end
    when 'reviews'
      # do nothing
    end # case
  end

  def new
    @page_title = "Submit New Listing"
    # if captcha validation fails, we need to re-render action
    # without losing existing field values
    if @listing == nil
      # @captcha = Captcha.generate
      @cities = City.find_all
      @listing = Listing.new
    end
  end

  def create
    @listing = Listing.new(params[:listing])
    # if !checkCaptcha
    #   flash[:error] = 'Incorrect verification code. Please try again.'
    #   @captcha = Captcha.generate
    #   render :action => 'new' and return
    # end
    if @listing.save
      @listing.update_attribute('active', 1)
      @listing.update_attribute('user_id', @session[:user]) unless is_admin?
      @listing.update_attribute('editor_approved', 1) unless is_admin?
      flash[:notice] = 'Thank-you. Your listing was successfully submitted.'
      redirect_to :controller => 'account', :action => 'index'
    else
      # @captcha = Captcha.generate
      render :action => 'new' and return
    end
  end

  def create_asset
    @asset = Asset.new(params[:asset])
    # @asset.listing_id = 1
    # @asset.asset_type = 'GENERAL'
    if @asset.save
      flash[:notice] = 'Image uploaded.'
      # redirect_to :action => 'show', :subaction => 'images', :id => params[:id]
      redirect_to :back
    else
      # @listing = Listing.find(@asset.listing_id)
      # render :action => 'show'
      params[:asset] = nil
      flash[:notice] = 'Image was not uploaded.'
      # redirect_to :back
      return :back
    end
  end

  def edit_asset
    @listing = Listing.find(params[:listing_id])
    @asset = Asset.find(params[:id])
  end

  def update_asset
    @asset = Asset.find(params[:id])
    # if @asset.update_attributes(params[:asset])
    if @asset
      if !params[:asset][:uploaded_data].blank? # image may still be stored by file_column
        if @asset.update_attributes(params[:asset])
          @asset.update_attribute('image', nil) if !@asset.image.nil?
        end
      else
        @asset.update_attribute('caption', params[:asset][:caption])
      end
      # @special.update_attribute('date_expires', nil) if params[:no_expiry_date]
      # @asset.update_attribute('image', nil) if params[:remove_image]
      flash[:notice] = "Image was successfully updated."
      case @asset.asset_type
      when 'GENERAL'
        subaction = 'images'
      when 'MENU'
        subaction = 'menu'
      when 'BROCHURE'
        subaction = 'brochure'
      else
        subaction = ''
      end
      redirect_to :controller => 'listings', :action => 'show', :id => @asset.listing_id, :subaction => subaction
      # redirect_to :back
    else
      redirect_to :back
      # render :action => 'show', :id => params[:id], :subaction => 'specials'
    end
  end

  def destroy_asset
    @asset = Asset.find(params[:id])
    if @asset
      # Make sure file_column image is destroyed
      @asset.update_attribute('image', nil)
      @asset.destroy
      flash[:notice] = 'Image deleted.'
    else
      flash[:notice] = 'Image could not be deleted.'
    end
    redirect_to :back
    # redirect_to :action => 'show', :subaction => 'images', :id => params[:listing_id]
  end

  def create_item
    @item = Item.new(params[:item])
    @item.date_expires = nil if params[:no_expiry_date]
    if @item.save
      case item_type
      when 'PRODUCT'
        flash[:notice] = 'Product saved.'
        subaction = 'products'
      when 'LUNCH_SPECIAL'
        flash[:notice] = 'Special saved.'
        subaction = 'specials'
      end
      redirect_to :action => 'show', :subaction => subaction, :id => params[:id]
    else
      flash[:notice] = 'Item could not be saved.'
      redirect_to :back
    end
  end

#  def live_search_original
#    @phrase = request.raw_post || request.query_string
#    a1 = "%"
#    a2 = "%"
#    @searchphrase = a1 + @phrase + a2
#    @results = Listing.find(:all, :conditions => ["active ='1' and business LIKE ?", @searchphrase])
#    @number_match = @results.length
#    render(:layout => false)
#  end

  def edit
    @page_title = "Edit Listing"
    @listing = Listing.find(params[:id])
    @user = User.find(session[:user])
    if (@listing.user_id == @user.id and @listing.editor_approved?) or is_admin?
      @cities = City.find_all
      @categories = Category.find_all
    else
      if @listing.user_id == @user.id and !@listing.editor_approved?
        flash[:error] = 'Sorry, your request to edit this listing has not yet been approved'
      else
        flash[:error] = 'Sorry, you are not authorized to edit this listing'
      end
      redirect_to :controller => 'listings', :action => 'show', :id => @listing
    end
  end

  def update
    # ! before update, verify current user is_admin, or is owner of current listing !
    @listing = Listing.find(params[:id])
    if @listing.update_attributes(params[:listing])
      flash[:notice] = 'Listing was successfully updated.'
      redirect_to :action => 'show', :id => @listing
    else
      render :action => 'edit'
    end
  end

  def destroy_file
    @listing = Listing.find(params[:id])
    if @listing
      @listing.update_attribute(params[:file], nil)
      flash[:notice] = 'Image file deleted.'
    else
      flash[:notice] = 'Listing not found!'
    end
    redirect_to :action => 'edit', :id => params[:id]
  end

  def destroy
    @listing = Listing.find(params[:id])
    if @listing
      @listing.update_attribute('image', nil)
      @listing.update_attribute('image1', nil)
      @listing.update_attribute('image2', nil)
      @listing.update_attribute('image3', nil)
      @listing.update_attribute('image4', nil)
      @listing.update_attribute('menu1', nil)
      @listing.update_attribute('menu2', nil)
      @listing.update_attribute('brochure1', nil)
      @listing.update_attribute('brochure2', nil)
      flash[:notice] = 'Listing deleted.'
    else
      flash[:notice] = 'Listing not found!'
    end
    redirect_to :action => 'list'
    #redirect_to :action => 'edit', :id => @listing
  end

  def claim_listing
    @page_title = "Claim This Listing"
    @listing = Listing.find(params[:id])
    if user_logged_in?
      # @existing_editor_listing = Listing.find_by_user_id(session[:user])
      if @listing.user_id == session[:user]
        flash[:notice] = "Your request was not submitted-- you are already the editor for the #{@listing.business}"
        redirect_back_or_default
        # redirect_to :back
      # else
      #   redirect_to :action => 'claim_this_listing', :id => params[:id]
      end
    else
      if !@listing
        flash[:notice] = "Listing not found."
        redirect_back_or_default
        # redirect_to :back
      end
    end
  end

  def claim_this_listing
    @listing = Listing.find(params[:id])
    if @listing.user_id > 0
      flash[:error] = 'This business has already been assigned an editor'
      redirect_to :controller => 'listings', :action => 'index'
    end
    @user = User.find(session[:user])
    @listing.update_attribute('user_id', session[:user])
    @listing.update_attribute('editor_approved', 0)
    UserNotify.deliver_claim_listing(@listing.business)
    flash[:notice] = "Your request to edit the listing for #{@listing.business} has been submitted."
    redirect_to :controller => 'listings', :action => 'index'
  end

  # This is for Pagination.
  DEFAULT_OPTIONS[:first_n] = nil
  def count_collection_for_pagination(model, options)
    unless options[:first_n].nil?
      return options[:first_n]
    else
      return model.count(:conditions => options[:conditions],
                         :joins => options[:join] || options[:joins],
                         :include => options[:include],
                         :select => options[:count])
    end
  end
  
  def tell_a_friend
  end
  
  def create_friend
    if request.post?
      @friend = Friend.new(params[:friend])
      if @friend.save
        begin
          UserNotify.deliver_tell_a_friend( @friend.sender_name, @friend.sender_email,
                                          @friend.name, @friend.email )
          flash[:notice] = "Email sent to #{@friend.name}. Thanks for telling a friend!"
        rescue
          flash[:error] = "Email could not be sent. Please try again"
        end
        redirect_to :action => 'index'
      else
        flash[:error] = 'Email could not be sent. Please try again.'
        redirect_back_or_default
        # redirect_to :back
      end
    end
  end

  def tell_a_friend_thanks
  end

  def driving_directions
    # redirect_to "http://maps.google.com/maps?saddr=steinbach+mb&daddr=grand+forks+nd", {:target => '_blank'}
  end

  def email_business
    @listing = Listing.find(params[:id])
  end

  def send_email_to_business
    if params[:name] == ''
      flash[:error] = "Your name cannot be blank"
    elsif params[:email] == ''
      flash[:error] = "Please specify your email address"
      redirect_to :back
    elsif params[:comments] == ''
      flash[:error] = "Comments cannot be blank"
    else
      @listing = Listing.find(params[:id])
      begin
        # email = UserNotify.create_email_business( params[:name],
        UserNotify.deliver_email_business( params[:name],
                                           params[:email],
                                           @listing.email,
                                           @listing.business,
                                           params[:comments] )
        # render(:text => "<pre>" + email.encoded + "</pre>")
        flash[:notice] = "Email sent to business. Thank-you for your inquiry."
      rescue
        flash[:notice] = "Sorry, your email message could not be delivered at this time. Please try again later."
      end
      redirect_to :back
    end
  end

  def stats
    @listing = Listing.find(params[:id])
    Hit.with_scope( :find => {:conditions => ["listing_id = ? and subaction <> ?", params[:id], '']} ) do
      @hits        = Hit.find( :all )
      @hits_today  = Hit.find( :all, :conditions => ["created_at >= ?", Date.today]  )
      @hits_week   = Hit.find( :all, :conditions => ["created_at >= ?", 1.weeks.ago] )
      @hits_month  = Hit.find( :all, :conditions => ["created_at >= ?", 30.days.ago] )
    end
    @hits_by_subaction = @hits.group_by{ |hit| hit.subaction }.sort
  end
  
  def stats_graph
    @id = params[:id]
    unless @id
      flash[:notice] = "No stats were found for that listing."
      redirect_to :action => 'show', :id => params[:id]
      # redirect_back_or_default
      # redirect_to :back
    end
    @listing = Listing.find(params[:id])

    # unless is_owner?(params[:id]) or is_admin?
    unless session[:user] and (is_admin? or is_owner?(params[:id]))
      flash[:notice] = "The stats page can only be accessed by the listing editor. (Are you logged in?)"
      redirect_to :action => 'show', :id => params[:id]
      # redirect_back_or_default
      # redirect_to :back
    end
    
    # Hit.with_scope( :find => {:conditions => ["listing_id = ? and subaction <> ?", params[:id], '']} ) do
    #   @hits        = Hit.find( :all )
    #   @hits_today  = Hit.find( :all, :conditions => ["created_at >= ?", Date.today]  )
    #   @hits_week   = Hit.find( :all, :conditions => ["created_at >= ?", 1.weeks.ago] )
    #   @hits_month  = Hit.find( :all, :conditions => ["created_at >= ?", 30.days.ago] )
    # end

    @hits        = Hit.find(:all, :conditions => ["listing_id = ? and subaction <> ?", params[:id], ''] )
    # @hits_today  = Hit.find(:all, :conditions => ["listing_id = ? and created_at >= ?", params[:id], Date.today] )
    # @hits_week   = Hit.find(:all, :conditions => ["listing_id = ? and created_at >= ?", params[:id], 1.weeks.ago] )
    # @hits_month  = Hit.find(:all, :conditions => ["listing_id = ? and created_at >= ? and subaction <> ?", params[:id], 30.days.ago, ''] )

    g = Gruff::Pie.new(600) 
    # g = Gruff::Bar.new(500) 
    g.font = "Library/Fonts/Arial" 
    g.legend_font_size = 18
    g.labels = { 0 => 'one', 1 => 'two', 2 => 'three', 3 => 'four', 4 => 'five', 5 => 'six', 6 => 'seven', 7 => 'eight', 8 => 'nine'}
    # g.x_axis_label = 'Sub-section'
    # g.y_axis_label = 'Visits'
    g.title = "Total Visits (#{@hits.size}) By Sub-Section*"
    g.title_font_size = 24
    g.marker_font_size = 18

    # g.theme_keynote
    g.theme = {
       :colors => %w(#66f #6f6 #f66 #ff6, #f6f),
       :marker_color => 'blue',
       :background_colors => %w(white white)
     }

    @hits_by_subaction = @hits.group_by{ |hit| hit.subaction }.sort
    @hits_by_subaction.each do |subaction, hit|
      g.data("#{subaction}", [hit.size])
    end

    send_data( g.to_blob,
    	:disposition => 'inline', 
    	:type => 'image/png', 
    	:filename => "graph.png" )

    # Save graph to image file
    # begin
    #   fname = File.join(RAILS_ROOT, "public", "images", "graph_#{@listing.id}.png")
    #   # fname = "public/images/graph_#{@listing.id}.png"
    #   g.write(fname)
    #   # flash[:notice] = "Graph written to: #{fname}"
    # rescue
    #   flash[:notice] = "Sorry, the graph could not be generated right now."
    # end

  end # // stats_graph

  def move_higher
    Asset.find(params[:id]).move_higher
    redirect_to :back
  end

  def move_lower
    Asset.find(params[:id]).move_lower
    redirect_to :back
  end

  def move_top
    Asset.find(params[:id]).move_to_top
    redirect_to :back
  end
  
  def move_bottom
    Asset.find(params[:id]).move_to_bottom
    redirect_to :back
  end

  # def sort_list(list_type, )
  # 
  #   listing_id = params[:id]
  #   subaction = params[:subaction]
  # 
  # 
  #   list.
  #   @grocery_list.food_items.each do |food_item| 
  #     food_item.position = params['grocery-list'].index(food_item.id.to_s) + 1 
  #     food_item.save 
  #   end 
  #   render :nothing => true 
  # end
  
  def cancel_edit_asset
    subaction = params[:subaction] == 'general' ? 'images' : params[:subaction]
    redirect_to_url "/listings/show/#{params[:id]}/#{subaction}"
  end
  
  def add_comment
    # @listing = Listing.find(params[:id])    
    @comment = Comment.new(params["comment"])
    # @comment.listing_id = @listing
    @comment.listing_id = params[:id]
    @comment.user_id = session[:user]

    if request.post? and @comment.save      
      headers["Content-Type"] = "text/html; charset=utf-8"
      render(:partial => "comment")
    else
      render(:partial => "comment_error")
    end
  end  

  def destroy_comment
    if user_logged_in? and is_admin?
      Comment.find(params[:id]).destroy
      flash[:notice] = 'Comment deleted.'
      redirect_to :back
    end
  end
  
  def toggle_featured
    @listing = Listing.find(params[:id])
    @listing.update_attribute('featured', !@listing.featured) if @listing
    redirect_to :back
  end
  
end
