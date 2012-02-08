class ContactMailer < ActionMailer::Base

  def contact(name, email, comments, sent_at = Time.now)
    @subject          = 'Comments from CacheValleySearch website'
    @recipients       = 'webmaster@cachevalleysearch.com'
    @from             = email
    @sent_on          = sent_at
    @headers          = {}
    # Email body substitutions
    @body['name']     = name
    @body['comments'] = comments
  end

end
