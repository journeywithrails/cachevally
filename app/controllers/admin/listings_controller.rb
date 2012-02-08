class Admin::ListingsController < ApplicationController

  before_filter :check_admin_authentication
  
  layout 'admin'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @today = Date.today
    @pending_listings = Listing.find :all,
                                     :conditions => ["user_id != \"\" AND editor_approved != 1"],
                                     :order => "created_on ASC"
#                                     :conditions => ["user_id IS NOT NULL AND user_id != '' AND editor_approved != 0"],
#                                     :conditions => ["user_id IS NOT NULL AND user_id != ? AND editor_approved != ?", "", 0],

    @inactive_listing_pages, @inactive_listings = paginate :listings,
                                         :per_page => 10,
                                         :conditions => ["active = ?", "0"],
                                         :order => "business ASC"

    @listing_pages, @listings = paginate :listings,
                                         :per_page => 50,
                                         :conditions => ["active = ?", "1"],
                                         :order => "business ASC"

    @paid_listing_pages, @paid_listings = paginate :listings,
                                         :per_page => 50,
                                         :conditions => ["date_paid_start <= ? and date_paid_expires > ?", @today, @today],
                                         :order => "business ASC"

  end

  def activate
    @listing = Listing.find(params[:id])
    @listing.update_attribute('active', '1')
    redirect_to :action => 'list'
  end

  def deactivate
    @listing = Listing.find(params[:id])
    @listing.update_attribute('active', '0')
    redirect_to :action => 'list'
  end

  def approve_editor
    if request.post?
      @listing = Listing.find(params[:id])
      @listing.update_attribute('editor_approved', '1')
      @listing.update_attribute('approver_id', session[:user] )
      @listing.update_attribute('approved_on', Time::now)
      @user = User.find(@listing.user_id)
      # send email notification to user
      @account_url = url_for :controller => '/account', :action => 'index'
      @listing_url = url_for :controller => '/listings', :action => 'show', :id => @listing
      begin
        UserNotify.deliver_editor_approved(@user, @listing, @account_url, @listing_url)
      rescue
      end
      flash[:notice] = "#{@listing.user.name} was approved as the editor for the '#{@listing.business}' listing."
      redirect_back_or_default :action => 'list'
      # redirect_to :action => 'list'
    end
  end

  def deny_editor
    if request.post?
      @listing = Listing.find(params[:id])
      @user = User.find(@listing.user_id)
      @listing.update_attribute('user_id', 0)
      flash[:notice] = "#{@user.name}'s request was denied."
      # send email notification to user
      redirect_back_or_default :action => 'list'
      # redirect_to :action => 'list'
    end
  end
  
  def show
    @today = Date.today
    @listing = Listing.find(params[:id])
    if @listing.approver_id then
      @approver = User.find(@listing.approver_id)
    end
#    @category = Category.find(@listing.category_id)
  end

  def edit
    @cities = City.find_all
    @categories = Category.find_all
    @listing = Listing.find(params[:id])
  end

  def update
    @listing = Listing.find(params[:id])
    if @listing.update_attributes(params[:listing])
      flash[:notice] = 'Listing was successfully updated.'
      redirect_to :action => 'show', :id => @listing
    else
      render :action => 'edit'
    end
  end

  def destroy
    Listing.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def live_search
    @phrase = params[:phrase]
    @trim_phrase = @phrase.gsub(/^\s+/, "").gsub(/\s+$/, $/)
    if @trim_phrase == nil or @trim_phrase == '' or @trim_phrase.size < 3
      @number_match = 0
      @results = nil
    else
      @searchphrase = "%" + @phrase + "%"
    # @phrase = request.raw_post || request.query_string
    # @trim_phrase = @phrase.gsub(/^\s+/, "").gsub(/\s+$/, $/)
    # if @trim_phrase == nil or @trim_phrase == '' or @trim_phrase.size < 3
    #   @number_match = 0
    #   @results = nil
    # else
    #   a1 = "%"
    #   a2 = "%"
    #   @searchphrase = a1 + @phrase + a2
      @results = Listing.find(
        :all,
        :conditions => ["active = '1' AND (business LIKE ? OR keywords LIKE ?)", @searchphrase, @searchphrase] )
      @number_match = @results.length
    end
    render(:layout => false)
  end

end
