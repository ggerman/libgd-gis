require_relative "basemap"
require_relative "projection"
require_relative "classifier"
require_relative "layer_geojson"
require_relative "layer_points"
require_relative "layer_lines"
require_relative "layer_polygons"

module GD
  module GIS
    attr_accessor :debug

    class Map
      TILE_SIZE = 256

      attr_reader :image
      attr_reader :layers
      attr_accessor :style

      def initialize(
        bbox:,
        zoom:,
        basemap:,
        width: nil,
        height: nil,
        crs: nil,
        fitted_bbox: false
      )
        # --------------------------------------------------
        # 1. Basic input validation
        # --------------------------------------------------
        raise ArgumentError, "bbox must be [min_lng, min_lat, max_lng, max_lat]" unless
          bbox.is_a?(Array) && bbox.size == 4

        raise ArgumentError, "zoom must be an Integer" unless zoom.is_a?(Integer)

        if (width && !height) || (!width && height)
          raise ArgumentError, "width and height must be provided together"
        end

        @zoom   = zoom
        @width  = width
        @height = height

        # --------------------------------------------------
        # 2. CRS normalization (input → WGS84 lon/lat)
        # --------------------------------------------------
        if crs
          normalizer = GD::GIS::CRS::Normalizer.new(crs)

          min_lng, min_lat = normalizer.normalize(bbox[0], bbox[1])
          max_lng, max_lat = normalizer.normalize(bbox[2], bbox[3])

          bbox = [min_lng, min_lat, max_lng, max_lat]
        end

        # --------------------------------------------------
        # 3. Final bbox (viewport-aware if width/height)
        # --------------------------------------------------
        @bbox =
          if width && height && !fitted_bbox
            GD::GIS::Geometry.viewport_bbox(
              bbox: bbox,
              zoom: zoom,
              width: width,
              height: height
            )
          else
            bbox
          end

        # --------------------------------------------------
        # 4. Basemap (uses FINAL bbox)
        # --------------------------------------------------
        @basemap = GD::GIS::Basemap.new(zoom, @bbox, basemap)

        # --------------------------------------------------
        # 5. Legacy semantic layers (REQUIRED by render)
        # --------------------------------------------------
        @layers = {
          motorway:  [],
          primary:   [],
          secondary: [],
          street:    [],
          minor:     [],
          rail:      [],
          water:     [],
          park:      []
        }

        # Optional alias (semantic clarity, no behavior change)
        @road_layers = @layers

        # --------------------------------------------------
        # 6. Overlay layers (generic)
        # --------------------------------------------------
        @points_layers   = []
        @lines_layers    = []
        @polygons_layers = []

        # --------------------------------------------------
        # 7. Style
        # --------------------------------------------------
        @style = nil

	      @debug = false
      end

      def features_by_layer(layer)
        return [] unless @layers[layer]

        @layers[layer].map do |item|
          item.is_a?(Array) ? item.last : item
        end
      end

      def features
        @layers.values.flatten.map do |item|
          item.is_a?(Array) ? item.last : item
        end
      end

      # -----------------------------------
      # GeoJSON input (unchanged behavior)
      # -----------------------------------
      def add_geojson(path)
        features = LayerGeoJSON.load(path)

        features.each do |feature|
          case feature.layer
          when :water
            kind =
              case (feature.properties["objeto"] || feature.properties["waterway"]).to_s.downcase
              when /river|río/     then :river
              when /stream|arroyo/ then :stream
              else :minor
              end

            @layers[:water] << [kind, feature]

          when :roads
            @layers[:street] << feature

          when :parks
            @layers[:park] << feature

          when :track
            # elegí una:
            @layers[:minor]  << feature
            # o @layers[:street] << feature
          else
            geom_type = feature.geometry["type"]

            if geom_type == "Point"
              points_style = @style.points or
                raise ArgumentError, "Style error: missing 'points' section"

              font = points_style[:font] or
                raise ArgumentError, "Style error: points.font is required"

              size = points_style[:size] or
                raise ArgumentError, "Style error: points.size is required"

              raw_color = points_style[:color]
              color = @style.normalize_color(raw_color)

              icon  = points_style.key?(:icon_fill) && points_style.key?(:icon_stroke) ? [points_style[:icon_stroke], points_style[:icon_stroke]] : nil
              icon  = points_style.key?(:icon) ? points_style[:icon] : nil if icon.nil?

              @points_layers << GD::GIS::PointsLayer.new(
                [feature],
                lon:   ->(f) { f.geometry["coordinates"][0] },
                lat:   ->(f) { f.geometry["coordinates"][1] },
                icon:  icon,
                label: ->(f) { f.properties["name"] },  # 👈 TEXTO
                font:  font,
                size:  size,
                color: color
              )
            elsif geom_type == "LineString" || geom_type == "MultiLineString"
              @layers[:minor] << feature
            end
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
      # Rendering (LEGACY, UNCHANGED)
      # -----------------------------------
      def render
        unless @basemap.tileable?
          @image = GD::Image.new(@width || 1024, @height || 1024)
          @basemap.render(self)
          return
        end

        if @width && @height
          render_viewport
        else
          render_tiles
        end
      end
      
      def render_tiles
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

        # 1️⃣ GeoJSON semantic layers
        @style.order.each do |kind|
          draw_layer(kind, projection)
        end

        # 2️⃣ Generic overlays
        @polygons_layers.each { |l| l.render!(@image, projection) }
        @lines_layers.each    { |l| l.render!(@image, projection) }
        @points_layers.each   { |l| l.render!(@image, projection) }
      end

      def render_viewport
        raise "map.style must be set" unless @style

        @image = GD::Image.new(@width, @height)
        @image.antialias = false

        # --------------------------------------------------
        # 1. Compute global pixel bbox
        # --------------------------------------------------
        min_lng, min_lat, max_lng, max_lat = @bbox

        x1, y1 = GD::GIS::Projection.lonlat_to_global_px(min_lng, max_lat, @zoom)
        x2, y2 = GD::GIS::Projection.lonlat_to_global_px(max_lng, min_lat, @zoom)

        # --------------------------------------------------
        # 2. Fetch tiles
        # --------------------------------------------------
        tiles, = @basemap.fetch_tiles

        # --------------------------------------------------
        # 3. Draw tiles clipped to viewport
        # --------------------------------------------------
        tiles.each do |x, y, file|
          tile = GD::Image.open(file)

          tile_x = x * TILE_SIZE
          tile_y = y * TILE_SIZE

          dst_x = tile_x - x1
          dst_y = tile_y - y1

          src_x = [0, -dst_x].max
          src_y = [0, -dst_y].max

          draw_w = [TILE_SIZE - src_x, @width  - dst_x - src_x].min
          draw_h = [TILE_SIZE - src_y, @height - dst_y - src_y].min

          next if draw_w <= 0 || draw_h <= 0

          @image.copy(
            tile,
            dst_x + src_x,
            dst_y + src_y,
            src_x,
            src_y,
            draw_w,
            draw_h
          )
        end

        # --------------------------------------------------
        # 4. Projection (viewport version)
        # --------------------------------------------------
        projection = lambda do |lon, lat|
          GD::GIS::Geometry.project(lon, lat, @bbox, @zoom)
        end

        # --------------------------------------------------
        # 5. REUSE the same render pipeline
        # --------------------------------------------------
        @style.order.each do |kind|
          draw_layer(kind, projection)
        end

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
          when :rail
            @style.rails
          when :water
            @style.water
          when :park
            @style.parks
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

              color = GD::GIS::ColorHelpers.random_vivid if @debug

              f.draw(@image, projection, color, width, :water)
            end
          else
            f = item
            geom = f.geometry["type"]

            if geom == "Polygon" || geom == "MultiPolygon"
              f.draw(@image, projection, nil, nil, style)
            else
              if style[:stroke]
                color = GD::Color.rgb(*style[:stroke])

                color = GD::GIS::ColorHelpers.random_vivid if @debug

                width = style[:stroke_width] ? style[:stroke_width].round : 1
                width = 1 if width < 1
                f.draw(@image, projection, color, width)
              end
            end
          end
        end
      end

    end
  end
end

