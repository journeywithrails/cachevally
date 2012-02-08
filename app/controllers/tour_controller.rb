class TourController < ApplicationController

  layout 'default'

  def index
    redirect_to :action => 'homepage'
  end

  def homepage
    @page_title = "Tour: Homepage"
  end

  def browse_by_city
    @page_title = "Tour: Browse by City"
  end

  def submit_new_listing
    @page_title = "Tour: Submit New Listing"
  end
  
  def listing_detail
    @page_title = "Tour: Listing Detail"
  end

  def my_account
    @page_title = "Tour: My Account"
  end

  def is_this_your_listing
    @page_title = "Tour: Is This Your Listing?"
  end
  
  
end
