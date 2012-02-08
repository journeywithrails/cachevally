require 'image_science'
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module ImageScienceProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end

        module ClassMethods
          # Yields a block containing an RMagick Image for the given binary data.
          def with_image(file, &block)
            ::ImageScience.with_image file, &block
          end
        end

        protected
          def process_attachment_with_processing
            return unless process_attachment_without_processing && image?
            with_image do |img|
              self.width  = img.width  if respond_to?(:width)
              self.height = img.height if respond_to?(:height)
              resize_image_or_thumbnail! img
            end
          end

          # Performs the actual resizing operation for a thumbnail
          # Updated as per http://iandrysdale.com/2007/05/22/cropped-thumbnails-in-attachment_fu-using-mini_magick/
          def resize_image(img, size)
            size = size.first if size.is_a?(Array) && size.length == 1
            if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
              if size.is_a?(Fixnum)
                size = [size, size]
                img.resize(size.join('x'))
              else
                img.resize(size.join('x') + '!')
              end
            else
              n_size = [img[:width], img[:height]] / size.to_s
              if size.ends_with? "!"
                aspect = n_size[0].to_f / n_size[1].to_f
                ih, iw = img[:height], img[:width]
                w, h = (ih * aspect), (iw / aspect)
                w = [iw, w].min.to_i
                h = [ih, h].min.to_i
                if ih > h
                  shave_off =  ((ih - h) / 2).round
                  img.shave("0x#{shave_off}")
                end
                if iw > w
                  shave_off = ((iw - w ) / 2).round
                  img.shave("#{shave_off}x0")
                end
                img.resize(size.to_s)
              else
                img.resize(size.to_s)
              end
              self.temp_path = img
            end
          end

          # Performs the actual resizing operation for a thumbnail
          # def resize_image(img, size)
          #   # create a dummy temp file to write to
          #   filename.sub! /gif$/, 'png'
          #   self.temp_path = write_to_temp_file(filename)
          #   grab_dimensions = lambda do |img|
          #     self.width  = img.width  if respond_to?(:width)
          #     self.height = img.height if respond_to?(:height)
          #     img.save temp_path
          #     callback_with_args :after_resize, img
          #   end
          # 
          #   size = size.first if size.is_a?(Array) && size.length == 1
          #   if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
          #     if size.is_a?(Fixnum)
          #       img.thumbnail(size, &grab_dimensions)
          #     else
          #       img.resize(size[0], size[1], &grab_dimensions)
          #     end
          #   else
          #     new_size = [img.width, img.height] / size.to_s
          #     img.resize(new_size[0], new_size[1], &grab_dimensions)
          #   end
          # end

      end
    end
  end
end