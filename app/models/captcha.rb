require 'RMagick'
require 'digest/md5'
class Captcha < ActiveRecord::Base

  def Captcha.generate
    # creates a new captcha row and returns a Captcha object.

    # make codes from 10000 to 99999, this ensures 5 digits
    code = 10000 + rand(89999)
    # generate a random hash
    hash = Digest::MD5.new(rand.to_s).hexdigest
    captcha = Captcha.new(:code => code)
    captcha.save
    return captcha
  end

  def to_jpegBlob
    # renders the captcha to an image and returns a binary blob of jpeg data

    codeString = self.code.to_s

    text = Magick::Draw.new
    # increase / decrease font size to taste, note I've added randomness to it
    text.pointsize = 20 + rand(5)
    text.gravity = Magick::CenterGravity
    # get the dimension of how the text will render
    metric = text.get_type_metrics(codeString)

    # create a canvas with 10 pixels wider/taller than the text
    canvas = Magick::ImageList.new
    canvas.new_image(metric.width+10, metric.height+10) {
      self.background_color = 'white'
    }

    # create a solid black halo/outline around the text by repeatedly drawing it
    # while sweeping it around a tight radius
    steps = 16
    radius = 1
    steps.times { |a|
      x = (Math.sin( (a.to_f/steps) * Math::PI * 2 ) * radius).to_i
      y = (Math.cos( (a.to_f/steps) * Math::PI * 2 ) * radius).to_i
      text.annotate(canvas, canvas.columns, canvas.rows, x, y, codeString) {
        self.fill = 'black'
      }
    }

    # draw the text in white over the black halo, but rotate it slightly. the idea here
    # is to make outline detection difficult by piercing the black outline with the
    # rotated white text.
    text.annotate(canvas, canvas.columns, canvas.rows, 0, 0, codeString) {
      self.fill = 'white'
      # rotate by either 6 or -6 degrees
      self.rotation = (rand(2)==1 ? 6 : -6)
    }
    new_image = canvas.to_blob { |img| img.format = 'JPEG' }
    # Done with RMagick, so trigger GC to get rid of those pesky objects
    GC.start
    return new_image
    
  end

end
