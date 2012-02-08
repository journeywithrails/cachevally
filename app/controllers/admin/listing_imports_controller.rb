class Admin::ListingImportsController < ApplicationController

  before_filter :check_admin_authentication
  layout 'admin'

  def index
    list
    render :action => 'list'
  end
  
  def list
    per_page = 20
    @imports = ListingImport.find(
      :all,
      :order => 'business ASC').paginate( params[:page] || session[:imports_page] || 1, per_page )
    # session[:old_page] = session[:imports_page]
    session[:imports_page] = (params[:page] || session[:imports_page] || 1)
  end

  def list_matched
    per_page = 20
    @imports = ListingImport.find(
      :all,
      :conditions => ['listing_id IS NOT NULL OR listing_id != ?', '' ],
      :order => 'business ASC').paginate( params[:page] || 1, per_page )
  end

  def list_unmatched
    per_page = 20
    @imports = ListingImport.find(
      :all,
      :conditions => ['listing_id IS NULL OR listing_id = ?', '' ],
      :order => 'business ASC').paginate( params[:page] || 1, per_page )
  end

  def show
    @listing = ListingImport.find(params[:id])
  end

  def edit
    @import = ListingImport.find(params[:id])
    @business_match = @import.business.to_s.strip[0,7] + "%"
    @address_match = @import.address.to_s.strip[0,7] + "%"
    @phone_match = @import.phone
    @matches = Listing.find(
      :all,
      :conditions => ["business LIKE ? OR address LIKE ? OR phone LIKE ?", @business_match, @address_match, @phone_match]
    )
    # @google_search = ERB::Util::url_encode(@import.business + " " + @import.address||"" + " " + @import.city||"Logan" + " " + @import.state||"UT")
    s = ''
    s << @import.business
    s << ' ' << (@import.address.nil? ? ' ' : @import.address)
    s << ' ' << (@import.city.nil? ? 'Logan' : @import.city)
    s << ' ' << (@import.state.nil? ? 'UT' : @import.state)
    @google_search = ERB::Util::url_encode(s)
  end

  def preview
    @listing = Listing.find(params[:id])
  end

  def merge
    @import = ListingImport.find(params[:id])
    if params[:new]
      @listing = Listing.new(params[:import])
      @listing.date_paid_start ||= '2007-01-01'
      @listing.date_paid_expires ||= '2007-01-01'
      @listing.imported_on = DateTime.now()
      @listing.active = 1
      if @listing.save
        @import.update_attribute('listing_id', @listing.id)
        flash[:notice] = "New listing created: #{@listing.business}"
        redirect_to :action => 'list'
      else
        flash[:notice] = "New listing could not be created."
        render :action => 'edit' and return
      end
    else # if params[:merge]
      # @import_id = params[:import][:listing_id]
      # flash[:notice] = "You selected record id: " + params[:import][:listing_id]
      @listing = Listing.find(params[:import][:listing_id])
      if @listing
        @listing.date_paid_start ||= '2007-01-01'
        @listing.date_paid_expires ||= '2007-01-01'
        @listing.business = params[:import][:business]
        @listing.address = params[:import][:address]
        @listing.address2 = params[:import][:address2]
        @listing.city = params[:import][:city]
        @listing.state = params[:import][:state]
        @listing.zip = params[:import][:zip]
        @listing.phone = params[:import][:phone]
        @listing.keywords = params[:import][:keywords]
        @listing.active = 1
        @listing.imported_on = DateTime.now()
        if @listing.save
          flash[:notice] = "Destination listing was updated: #{@listing.business}."
          @import.update_attribute('listing_id', params[:import][:listing_id])
          redirect_to :action => 'list'
        else
          flash[:error] = "Destination listing NOT updated."
          render :action => 'edit' and return
        end
      else
        flash[:error] = "The destination listing could not be located (id: #{@import_id})"
        redirect_to :back
      end
    end

    
    # @destination_listing = Listing.Find()

    # if params[:import_id].blank?
    #   flash[:error] = "You must select/specify a record from the live database to merge with."
    #   redirect_to :back
    # else
    #   flash[:notice] = "You selected record id: " + params[:import_id]
    # end
    
  end
  
end
