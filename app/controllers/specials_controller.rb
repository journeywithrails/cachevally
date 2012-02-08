class SpecialsController < ApplicationController

  layout 'default'

  def index
    list
    render :action => 'list'
  end

  def list
    # @specials = Special.find_active_specials(true, params[:page], params[:sort])
    # :conditions => ["date_expires is ? or date_expires >= ? and sp.listing_id = li.id", nil, Date::today],
    # @posts = Post.paginate_by_board_id @board.id, :page => params[:page]

    case params[:sort]
    when 'price'
      sort_by = 'price DESC'
    when 'business'
      sort_by = 'li.business ASC'
    when 'expiry'
      sort_by = 'date_expires ASC'
    else
      sort_by = 'li.business ASC'
    end

    per_page = 10
    @specials = Special.find_active_specials(sort_by).paginate( (params[:page] || 1), per_page )
    
    # @specials = Special.paginate(
    #   :all,
    #   :joins      => "as sp join listings as li on sp.listing_id = li.id",
    #   :select     => 'sp.id, sp.title, sp.date_expires, sp.description, sp.cost, sp.image, sp.listing_id, li.business',
    #   :conditions => ["date_expires is ? or date_expires >= ?", nil, Date::today],
    #   :order => sort_by,
    #   :limit => 100,
    #   :page => params[:page]||= 1, :per_page => 10 )

  end

  def new
    @listing = Listing.find(params[:id])
    @special = Special.new
    @special.date_expires = 30.day.from_now
    # @special.assets.build # build an empty asset for image upload
  end

  # this method stops program from saving the asset if the field is blank,
  # and returns type-errors if relevant (files not PDF)
  def validate_and_build_special_images(fileParams,file)
    # if Asset2.is_valid_file?(file)
       @special_image = @special.special_images.build(fileParams)
    # end
  end

  def create
    @special = Special.new(params[:special])
    @listing = Listing.find(params[:id])

    validate_and_build_special_images(params[:special_image], params[:special_image][:uploaded_data]) unless params[:special_image][:uploaded_data].blank?

    # @special.date_active = now()
    @special.date_expires = '2999-12-31 23:59:59' if params[:no_expiry_date]
    #v@special.cost = 0 if params[:cost].nil?
    if @special.save
      flash[:notice] = 'Special saved.'
      redirect_to :controller => 'listings', :action => 'show', :id => params[:id], :subaction => 'specials'
    else
      flash[:notice] = 'Special could not be saved.'
      # redirect_to :back
      # render :action => 'new' and return
      render :controller => 'specials', :action => 'new'
    end
  end

  def edit
    @special = Special.find(params[:id])
    @listing = Listing.find(@special.listing_id)
  end

  def update
    @special = Special.find(params[:id])
    if @special.update_attributes(params[:special])
      @special.update_attribute('date_expires', nil) if params[:no_expiry_date]
      @special.special_images.each { |image| image.destroy } if params[:remove_image_fu] # clean-up if image stored as asset
      @special.update_attribute('image', nil) if params[:remove_image] # clean-up if image stored in special (file_column)

      # delete any existing image (.special_images) before uploading new image
      if !params[:special_image][:uploaded_data].blank?
        @special.special_images.each { |image| image.destroy }
        @special.special_images.build(params[:special_image])
        @special.save
        flash[:notice] = "Special '#{@special.title}' was successfully updated, new image uploaded."
      else
        flash[:notice] = "Special '#{@special.title}' was successfully updated."
      end

      # flash[:notice] = "Special '#{@special.title}' was successfully updated."
      redirect_to :controller => 'listings', :action => 'show', :id => @special.listing_id, :subaction => 'specials'
    else
      @listing = Listing.find(@special.listing_id)
      render :action => 'edit'
      # redirect_to :back
    end
  end

  def show
    @special = Special.find(params[:id])
  end

  def destroy
    @special = Special.find(params[:id])
    if @special
      # Make sure file_column image is destroyed
      @special.update_attribute('image', nil)
      @special.destroy
      flash[:notice] = 'Special deleted.'
    else
      flash[:notice] = 'Special could not be deleted.'
    end
    redirect_to :back
  end

  def feed
    @specials = Special.find_active_specials
    render  :layout =>  false
  end

  def print
    @special = Special.find(params[:id])
    @listing = Listing.find(@special.listing_id)
    render :action => "print", :layout => "print_coupon"
  end

  def forward_to_a_friend
    @special = Special.find(params[:id])
    @listing = Listing.find(@special.listing.id)
    # @has_image = !(@special.image.nil? or @special.image == '')
  end

  def email_special

    if request.post?
      @friend = Friend.new(params[:friend])
      if @friend.save
        begin
          SpecialNotify.deliver_forward_to_a_friend( @friend.sender_name,
                                                  @friend.sender_email,
                                                  @friend.name,
                                                  @friend.email,
                                                  @friend.special_id )
          flash[:notice] = "Special/Coupon was forwarded to #{@friend.name}."
        # rescue
          # flash[:error] = "Email could not be sent. Please try again"
        end
        redirect_to :action => 'index'
      # else
        # flash[:error] = 'Email could not be sent. Please try again.'
        # redirect_back_or_default
        # # redirect_to :back
      end
    end

    # @special = Special.find(params[:id])
    # @listing = Listing.find(@special.listing.id)
    # if params[:name] == '' or params[:email] == ''
    #   flash[:error] = 'Please enter your name and email address'
    #   render :action => 'forward_to_a_friend'
    # elsif params[:friend1] == '' and params[:friend2]== '' and params[:friend3] == ''
    #   flash[:error] = 'Please enter the email address for at least one friend'
    #   render :action => 'forward_to_a_friend'
    # else
    #   @special = Special.find(params[:id])
    #   SpecialNotify.delivery_forward_to_a_friend(
    #     sender_name,
    #     sender_email,
    #     recipient_email,
    #     special_id,
    #     sent_at = Time.now )
    # end
  end
  
  def subscribe_email
  
  end

end
