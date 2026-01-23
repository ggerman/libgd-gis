require_relative "basemap"
require_relative "projection"
require_relative "classifier"
require_relative "layer_geojson"
require_relative "layer_points"
require_relative "layer_lines"
require_relative "layer_polygons"

module GD
  module GIS
    class Map
      TILE_SIZE = 256

      attr_reader :image
      attr_accessor :style

      def initialize(bbox:, zoom:, basemap:)
        @bbox     = bbox
        @zoom     = zoom
        @basemap  = Basemap.new(zoom, bbox, basemap)

        # 🔒 DO NOT CHANGE — this is the working GeoJSON pipeline
        @layers = {
          motorway: [],
          primary: [],
          secondary: [],
          street: [],
          minor: [],
          rail: [],
          water: [],
          park: []
        }

        # 🆕 overlay layers
        @points_layers   = []
        @lines_layers    = []
        @polygons_layers = []

        @style = nil
      end

      # -----------------------------------
      # GeoJSON input (unchanged)
      # -----------------------------------

      def add_geojson(path)
        features = LayerGeoJSON.load(path)

        features.each do |feature|
          if Classifier.water?(feature)
            kind = Classifier.water_kind(feature)
            @layers[:water] << [kind, feature]

          elsif Classifier.park?(feature)
            @layers[:park] << feature

          elsif Classifier.rail?(feature)
            @layers[:rail] << feature

          elsif type = Classifier.road(feature)
            @layers[type] << feature
          end
        end
      end

      # -----------------------------------
      # Overlay layers
      # -----------------------------------

      def add_points(data, **opts)
        @points_layers << GD::GIS::PointsLayer.new(data, **opts)
      end

      def add_lines(features, **opts)
        @lines_layers << GD::GIS::LinesLayer.new(features, **opts)
      end

      def add_polygons(polygons, **opts)
        @polygons_layers << GD::GIS::PolygonsLayer.new(polygons, **opts)
      end

      # -----------------------------------
      # Rendering
      # -----------------------------------

      def render
        raise "map.style must be set" unless @style

        tiles, x_min, y_min = @basemap.fetch_tiles

        xs = tiles.map { |t| t[0] }
        ys = tiles.map { |t| t[1] }

        cols = xs.max - xs.min + 1
        rows = ys.max - ys.min + 1

        width  = cols * TILE_SIZE
        height = rows * TILE_SIZE

        origin_x = x_min * TILE_SIZE
        origin_y = y_min * TILE_SIZE

        @image = GD::Image.new(width, height)
        @image.antialias = false

        # Basemap
        tiles.each do |x, y, file|
          tile = GD::Image.open(file)
          @image.copy(
            tile,
            (x - x_min) * TILE_SIZE,
            (y - y_min) * TILE_SIZE,
            0, 0, TILE_SIZE, TILE_SIZE
          )
        end

        projection = lambda do |lon, lat|
          x, y = GD::GIS::Projection.lonlat_to_global_px(lon, lat, @zoom)
          [(x - origin_x).round, (y - origin_y).round]
        end

        # 1️⃣ Semantic GeoJSON layers (this is what was working)
        @style.order.each do |kind|
          draw_layer(kind, projection)
        end

        # 2️⃣ Generic overlays
        @polygons_layers.each { |l| l.render!(@image, projection) }
        @lines_layers.each    { |l| l.render!(@image, projection) }
        @points_layers.each   { |l| l.render!(@image, projection) }
      end

      def save(path)
        @image.save(path)
      end

      def draw_layer(kind, projection)
        items = @layers[kind]
        return if items.nil? || items.empty?

        style =
          case kind
          when :street, :primary, :motorway, :secondary, :minor
            @style.roads[kind]
          when :rail   then @style.rails
          when :water  then @style.water
          when :park   then @style.parks
          else
            @style.extra[kind] if @style.respond_to?(:extra)
          end

        return if style.nil?

        items.each do |item|
          if kind == :water
            water_kind, f = item

            width =
              case water_kind
              when :river  then 2.5
              when :stream then 1.5
              else 1
              end

            if style[:stroke]
              color = GD::Color.rgb(*style[:stroke])
              f.draw(@image, projection, color, width, :water)
            end

          else
            f = item
            geom = f.geometry["type"]

            if geom == "Polygon" || geom == "MultiPolygon"
              # THIS is the critical fix
              f.draw(@image, projection, nil, nil, style)
            else
              if style[:stroke]
                color = GD::Color.rgb(*style[:stroke])
                width = style[:stroke_width] || 1
                f.draw(@image, projection, color, width)
              end
            end
          end
        end
      end


    end
  end
end
