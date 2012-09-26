Spree::Image.class_eval do
	has_many :colors, :dependent => :destroy
	after_create :find_colors

  require 'color_util'

	def find_colors 
		dom_colors = extract_colors
		
	end
  #T1qAp24Wrmirrorimagehome
	def extract_colors
    img = Magick::ImageList.new(self.attachment.to_file.path)
    q = img.quantize(50, Magick::RGBColorspace)
    palette = q.color_histogram.sort {|a, b| b[1] <=> a[1]}
    num_added = 0
    (0..50).each do |i|
      c = palette[i].to_s.split(',').map {|x| x[/\d+/]}
      c.pop
      c[0], c[1], c[2] = [c[0], c[1], c[2]].map { |s| 
        s = s.to_i
        if s / 255 > 0 # not all ImageMagicks are created equal....
          s = s / 255
        end
        s
      }
      hsv = ColorUtil.rgb_to_hsv(c[0], c[1], c[2])
      if hsv[:s] < 35.0 || hsv[:v] < 35.0
        next
      end
      color = Spree::Color.new({ :hue => hsv[:h], :sat => hsv[:s], :val => hsv[:v] })
      self.colors.push(color)
      num_added += 1
      break if num_added >= 7
    end
    self.save
  end

  
end