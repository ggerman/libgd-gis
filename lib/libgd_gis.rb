require "libgd_gis"

require "open-uri"
require "tempfile"
require "gd"

module LibGD
  module GIS
    class Tile
        attr_reader :z, :x, :y, :image

        def self.osm(z:, x:, y:)
        new(
            z: z,
            x: x,
            y: y,
            source: "https://api.maptiler.com/maps/basic/#{z}/#{x}/#{y}.png?key=GetYourOwnKey"
        )
        end

        def initialize(z:, x:, y:, source:)
            @z = z
            @x = x
            @y = y
            @source = source
        end

        def render
            tmp = Tempfile.new(["tile", ".png"])
            tmp.binmode
            tmp.write URI.open(@source).read
            tmp.flush

            @image = GD::Image.open(tmp.path)
        ensure
            tmp.close
        end

        def save(path)
            @image.save(path)
        end
    end
  end
end
