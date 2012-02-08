class SpecialNotify < ActionMailer::Base

  def forward_to_a_friend(sender_name, sender_email, recipient_name, recipient_email, special_id, sent_at = Time.now)
    @subject             = 'Check out this coupon (CacheValleySearch.com)'
    @recipients          = recipient_email
    @from                = sender_email
    @sent_on             = sent_at
    @headers             = {}
    # Email body substitutions
    @special = Special.find(special_id)
    @body[:business]     = @special.listing.business
    @body[:title]        = @special.title
    @body[:date_expires] = @special.date_expires
    @body[:description]  = @special.description
    @body[:print_url]    = "http://cachevalleysearch.com/specials/print/#{special_id}"
    @body[:to]           = recipient_name
    @body[:from]         = sender_name
  end

end
