require "chunky_png"

module ImageHelpers
  def load_png(path)
    ChunkyPNG::Image.from_file(path)
  end
end

RSpec.configure do |config|
  config.include ImageHelpers
end
