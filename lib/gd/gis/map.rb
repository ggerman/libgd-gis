require "gd"
require_relative "basemap"
require_relative "projection"
require_relative "layer_points"

module GD
  module GIS
    class Map
      def initialize(bbox:, zoom:, basemap:)
        @bbox = bbox
        @zoom = zoom
        @basemap = Basemap.new(zoom, bbox, basemap)
        @layers = []
      end

      def add_points(data, lon:, lat:, icon:)
        @layers << PointsLayer.new(data, lon: lon, lat: lat, icon: icon)
      end

      def render
        tiles, x_min, y_min = @basemap.fetch_tiles

        cols = tiles.map{|t| t[0]}.uniq.size
        rows = tiles.map{|t| t[1]}.uniq.size

        width = cols * 256
        height = rows * 256

        @img = GD::Image.new(width,height)

        tiles.each do |x,y,path|
          tile = GD::Image.open(path)
          cx = x - x_min
          cy = y - y_min
          @img.copy(tile, cx*256, cy*256, 0,0,256,256)
        end

        # projection bbox
        min_x = Projection.mercator_x(@bbox[0])
        max_x = Projection.mercator_x(@bbox[2])
        min_y = Projection.mercator_y(@bbox[1])
        max_y = Projection.mercator_y(@bbox[3])

        projector = ->(lon,lat) {
          Projection.lonlat_to_pixel(lon,lat,min_x,max_x,min_y,max_y,width,height)
        }

        @layers.each { |l| l.render!(@img, projector) }
      end

      def tile2lon(x, z)
        x.to_f / (2**z) * 360.0 - 180.0
      end

      def tile2lat(y, z)
        n = Math::PI - (2.0 * Math::PI * y.to_f) / (2**z)
        180.0 / Math::PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)))
      end

      def tile_bbox(z,x,y)
        west  = tile2lon(x, z)
        east  = tile2lon(x+1, z)
        north = tile2lat(y, z)
        south = tile2lat(y+1, z)
        [west, south, east, north]
      end

      def intersect_bbox(a,b)
        [
          [a[0], b[0]].max,
          [a[1], b[1]].max,
          [a[2], b[2]].min,
          [a[3], b[3]].min
        ]
      end

      def tile(z,x,y)
        tb = tile_bbox(z,x,y)
        ib = intersect_bbox(@bbox, tb)

        # Si no hay intersección, devolvemos tile vacío
        if ib[0] >= ib[2] || ib[1] >= ib[3]
          return GD::Image.new(256,256)
        end

        submap = GD::GIS::Map.new(
          bbox: ib,
          zoom: z,
          basemap: :carto_light
        )

        # copiar capas
        @layers.each { |l| submap.instance_variable_get(:@layers) << l }

        submap.render

        # recortar al tamaño exacto del tile
        img = GD::Image.new(256,256)
        img.copy(submap.instance_variable_get(:@img), 0,0,0,0,256,256)
        img
      end

      def save(path)
        @img.save(path)
      end
    end
  end
end
