class AboutController < ApplicationController

  layout 'default', :except => 'textile'

  def index
  end
  
  def contact
  end

  def send_email
    if request.post?
      ContactMailer.deliver_contact(params['name'], params['email'], params['comments'])
      redirect_to :action => 'contact_thanks'
    end
  end

  def stats
      @listings = Listing.find( :all,
                                :select => "id, business"
                              ).sort_by{ |x| x.hits.count }.reverse.first(10)
  end

  def stats2
  end
  
end
