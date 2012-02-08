# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def free_when_zero(price)
    return price if price.nil?
    if price.zero?
      "FREE"
    elsif price.is_numeric?
      number_to_currency(price)
    else
      price
    end
  end

  def nil_or_zero(i)
    (i || 0).zero?
  end

  def captchaImgTag(captcha)
    # return an image tag for a captcha.
    return('<img src="%s" alt="visual confirmation code" />' %
      h(url_for(:controller => 'captchas', :action => 'show', :id => captcha.id)))
  end

  def hiddenCaptchaInput(captcha)
    # returns hidden form input string to send the captcha id parameter
    # checkCaptcha() uses this parameter to load the captcha.
    return '' unless captcha
    return '<input type="hidden" name="captcha_id" value="%d"/>' % captcha.id
  end

  def textileThis(text)
    if text.blank?
      ""
    else
      RedCloth.new(text).to_html
    end
  end

  def abstract(str, max_len = 10)
    str.length <= max_len ? str : str[0..max_len-1] << '...'
  end

end
