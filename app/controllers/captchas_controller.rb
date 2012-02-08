class CaptchasController < ApplicationController
  def show
    # returns the rendered captcha to the client as an inline jpeg
    captcha = Captcha.find(@params[:id])
    send_data captcha.to_jpegBlob, :type=>'image/jpeg', :disposition=>'inline'
  end

end
