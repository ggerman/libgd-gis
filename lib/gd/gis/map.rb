require "gd"
require_relative "basemap"
require_relative "projection"
require_relative "geometry"
require_relative "layer_points"
require_relative "layer_lines"
require_relative "layer_polygons"

module GD
  module GIS
    class Map
      def initialize(bbox:, zoom:, basemap:)
        @bbox = bbox
        @zoom = zoom
        @basemap = Basemap.new(zoom, bbox, basemap)
        @layers = []
      end

      def add_points(data, lon:, lat:, icon: nil, label: nil, font: nil, size: 12, color: [0,0,0])
        @layers << PointsLayer.new(
          data,
          lon: lon,
          lat: lat,
          icon: icon,
          label: label,
          font: font,
          size: size,
          color: color
        )
      end

      def add_lines(features, stroke:, fill: nil, width:)
        if fill
          @layers << PolygonsLayer.from_lines(features,
            stroke: stroke,
            fill: fill,
            width: width
          )
        else
          @layers << LinesLayer.new(features,
            stroke: stroke,
            width: width
          )
        end
      end

      def add_polygons(polygons, fill:, stroke: nil, width: nil)
        @layers << PolygonsLayer.new(polygons, fill: fill, stroke: stroke, width: width)
      end

      def render
        tiles, x_min, y_min = @basemap.fetch_tiles

        # 🔥 Origen REAL del canvas en WebMercator global pixels
        origin_x = x_min * 256
        origin_y = y_min * 256

        x_vals = tiles.map { |t| t[0] }
        y_vals = tiles.map { |t| t[1] }

        cols = x_vals.max - x_vals.min + 1
        rows = y_vals.max - y_vals.min + 1

        width  = cols * 256
        height = rows * 256

        @img = GD::Image.new(width, height)
        @img.alpha_blending = true
        @img.save_alpha = true

        # Dibujar tiles en sistema LOCAL del mosaico
        tiles.each do |x, y, path|
          tile = GD::Image.open(path)
          cx = x - x_min
          cy = y - y_min
          @img.copy(tile, cx * 256, cy * 256, 0, 0, 256, 256)
        end

        # 🔥 Proyección correcta: global → local
        projection = ->(lon, lat) do
          gx, gy = GD::GIS::Projection.lonlat_to_global_px(lon, lat, @zoom)

          x = gx - origin_x
          y = gy - origin_y

          [x.round, y.round]
        end

        @layers.each { |l| l.render!(@img, projection) }
      end

      def tile2lon(x, z)
        x.to_f / (2**z) * 360.0 - 180.0
      end

      def tile2lat(y, z)
        n = Math::PI - (2.0 * Math::PI * y.to_f) / (2**z)
        180.0 / Math::PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)))
      end

      def tile_bbox(z, x, y)
        west  = tile2lon(x, z)
        east  = tile2lon(x + 1, z)
        north = tile2lat(y, z)
        south = tile2lat(y + 1, z)
        [west, south, east, north]
      end

      def intersect_bbox(a, b)
        [
          [a[0], b[0]].max,
          [a[1], b[1]].max,
          [a[2], b[2]].min,
          [a[3], b[3]].min
        ]
      end

      def tile(z, x, y)
        tb = tile_bbox(z, x, y)
        ib = intersect_bbox(@bbox, tb)

        if ib[0] >= ib[2] || ib[1] >= ib[3]
          return GD::Image.new(256, 256)
        end

        submap = GD::GIS::Map.new(
          bbox: ib,
          zoom: z,
          basemap: :carto_light
        )

        @layers.each { |l| submap.instance_variable_get(:@layers) << l }

        submap.render

        img = GD::Image.new(256, 256)
        img.alpha_blending = true
        img.save_alpha = true
        img.copy(submap.instance_variable_get(:@img), 0, 0, 0, 0, 256, 256)
        img
      end

      def save(path)
        @img.save(path)
      end
    end
  end
end
