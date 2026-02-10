# frozen_string_literal: true

require_relative "basemap"
require_relative "projection"
require_relative "classifier"
require_relative "layer_geojson"
require_relative "layer_points"
require_relative "layer_lines"
require_relative "layer_polygons"
require_relative "legend"

LINE_GEOMS = %w[LineString MultiLineString].freeze
POLY_GEOMS = %w[Polygon MultiPolygon].freeze

module GD
  module GIS
    # Represents a complete renderable map.
    #
    # A Map is responsible for:
    # - Managing the geographic extent (bounding box + zoom)
    # - Fetching and compositing basemap tiles
    # - Managing semantic feature layers
    # - Managing generic overlay layers (points, lines, polygons)
    # - Executing the rendering pipeline
    #
    # The map can render either:
    # - A full tile-based image, or
    # - A fixed-size viewport clipped from the basemap
    #
    class Map
      # Tile size in pixels (Web Mercator standard)
      TILE_SIZE = 256

      # @return [GD::Image, nil] rendered image
      attr_reader :image

      # @return [Hash<Symbol, Array>] semantic feature layers
      attr_reader :layers

      # @return [Object, nil] style object
      attr_accessor :style

      # @return [Boolean] enables debug rendering
      attr_reader :debug

      # Creates a new map.
      #
      # @param bbox [Array<Float>]
      #   bounding box [min_lng, min_lat, max_lng, max_lat]
      # @param zoom [Integer]
      #   zoom level
      # @param basemap [Symbol]
      #   basemap provider identifier
      # @param width [Integer, nil]
      #   viewport width in pixels
      # @param height [Integer, nil]
      #   viewport height in pixels
      # @param crs [String, Symbol, nil]
      #   input CRS identifier
      # @param fitted_bbox [Boolean]
      #   whether the provided bbox is already viewport-fitted
      #
      # @raise [ArgumentError] if parameters are invalid
      def initialize(
        bbox:,
        zoom:,
        basemap:,
        width: nil,
        height: nil,
        crs: nil,
        fitted_bbox: false
      )
        # 1. Basic input validation
        raise ArgumentError, "bbox must be [min_lng, min_lat, max_lng, max_lat]" unless
          bbox.is_a?(Array) && bbox.size == 4

        raise ArgumentError, "zoom must be an Integer" unless zoom.is_a?(Integer)

        raise ArgumentError, "width and height must be provided together" if (width && !height) || (!width && height)

        @zoom   = zoom
        @width  = width
        @height = height

        # 2. CRS normalization (input → WGS84 lon/lat)
        if crs
          normalizer = GD::GIS::CRS::Normalizer.new(crs)

          min_lng, min_lat = normalizer.normalize(bbox[0], bbox[1])
          max_lng, max_lat = normalizer.normalize(bbox[2], bbox[3])

          bbox = [min_lng, min_lat, max_lng, max_lat]
        end

        # 3. Final bbox (viewport-aware if width/height)
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

        # 4. Basemap (uses FINAL bbox)
        @basemap = GD::GIS::Basemap.new(zoom, @bbox, basemap)

        # 5. Legacy semantic layers (REQUIRED by render)
        @layers = {
          motorway:  [],
          primary:   [],
          secondary: [],
          street:    [],
          track:     [],
          minor:     [],
          rail:      [],
          water:     [],
          park:      []
        }

        # Optional alias (semantic clarity, no behavior change)
        @road_layers = @layers

        # 6. Overlay layers (generic)
        @points_layers   = []
        @lines_layers    = []
        @polygons_layers = []

        # 7. Style
        @style = nil

        @debug = false
        @used_labels = {}
        @count = 1
      end

      # Returns all features belonging to a given semantic layer.
      #
      # @param layer [Symbol]
      # @return [Array<Feature>]
      def features_by_layer(layer)
        return [] unless @layers[layer]

        @layers[layer].map do |item|
          item.is_a?(Array) ? item.last : item
        end
      end

      # Returns all features in the map.
      #
      # @return [Array<Feature>]
      def features
        @layers.values.flatten.map do |item|
          item.is_a?(Array) ? item.last : item
        end
      end

      # Creates a single text label for a named linear feature (LineString or
      # MultiLineString), avoiding duplicate labels for the same named entity.
      #
      # Many datasets (especially OSM) split a single logical entity
      # (rivers, streets, railways, etc.) into multiple line features that
      # all share the same name. This method ensures that:
      #
      # - Only one label is created per unique entity name
      # - The label is placed on a representative segment of the geometry
      # - The logic is independent of the feature's semantic layer (water, road, rail)
      #
      # Labels are rendered using a PointsLayer because libgd-gis does not
      # support text rendering directly on line geometries.
      #
      # The label position is chosen as the midpoint of the line coordinates.
      # This is a simple heuristic that provides a reasonable placement without
      # requiring geometry merging or topological analysis.
      #
      # @param feature [GD::GIS::Feature]
      #   A feature with a linear geometry and a "name" property.
      #
      # @return [void]
      #   Adds a PointsLayer to @points_layers if a label is created.
      #
      # @note
      #   This method must be called during feature loading (add_geojson),
      #   before rendering. It intentionally does not depend on map style
      #   configuration, which is applied later during rendering.
      def maybe_create_line_label(feature)
        return true if @style.global[:label] == false || @style.global[:label].nil?

        geom = feature.geometry
        return unless LINE_GEOMS.include?(geom["type"])

        name = feature.properties["name"]
        return if name.nil? || name.empty?

        key = feature.properties["wikidata"] || name
        return if @used_labels[key]

        coords = geom["coordinates"]
        coords = coords.flatten(1) if geom["type"] == "MultiLineString"
        return if coords.size < 2

        lon, lat = coords[coords.size / 2]

        @points_layers << GD::GIS::PointsLayer.new(
          [feature],
          lon:   ->(_) { lon },
          lat:   ->(_) { lat },
          icon: @style.global[:label][:icon],
          label: ->(_) { name },
          font:  @style.global[:label][:font] || GD::GIS::FontHelper.random,
          size:  @style.global[:label][:size] || (6..20).to_a.sample,
          color: @style.global[:label][:color] || GD::GIS::ColorHelpers.random_rgba
        )

        @used_labels[key] = true
      end

      def legend(position: :bottom_right)
        @legend = Legend.new(position: position)
        yield @legend
      end

      def legend_from_layers(position: :bottom_right)
        @legend = Legend.new(position: position)

        layers.each do |layer|
          next unless layer.respond_to?(:color)

          @legend.add(layer.color, layer.name)
        end
      end

      def draw_legend
        return unless @legend
        return unless @image
        return unless @style
        return unless @style.global
        return if @style.global[:label] == false

        label_style = @style.global[:label] || {}

        padding     = 10
        box_size    = 12
        line_height = 18
        margin      = 15

        # --- font (from style) -----------------------------------

        font_path =
          case label_style[:font]
          when nil, "default"
            GD::GIS::FontHelper.random
          else
            label_style[:font]
          end

        font_size  = label_style[:size] || 10
        font_color = GD::Color.rgba(*(label_style[:color] || [0, 0, 0, 0]))

        # --- measure text (CORRECT API) ---------------------------

        text_widths = @legend.items.map do |i|
          w, = @image.text_bbox(
            i.label,
            font: font_path,
            size: font_size
          )
          w
        end

        width  = (text_widths.max || 0) + box_size + (padding * 3)
        height = (@legend.items.size * line_height) + (padding * 2)

        # --- position --------------------------------------------

        x, y =
          case @legend.position
          when :bottom_right
            [@image.width - width - margin, @image.height - height - margin]
          when :bottom_left
            [margin, @image.height - height - margin]
          when :top_right
            [@image.width - width - margin, margin]
          else
            [margin, margin]
          end

        # --- background ------------------------------------------

        bg     = GD::Color.rgba(255, 255, 255, 80)
        border = GD::Color.rgb(200, 200, 200)

        @image.filled_rectangle(x, y, x + width, y + height, bg)
        @image.rectangle(x, y, x + width, y + height, border)

        # --- items -----------------------------------------------

        @legend.items.each_with_index do |item, idx|
          iy = y + padding + (idx * line_height)

          # color box
          @image.filled_rectangle(
            x + padding,
            iy,
            x + padding + box_size,
            iy + box_size,
            GD::Color.rgba(*item.color)
          )

          # label text
          @image.text_ft(
            item.label,
            x: x + padding + box_size + 8,
            y: iy + box_size,
            font: font_path,
            size: font_size,
            color: font_color
          )
        end
      end

      # Loads features from a GeoJSON file.
      #
      # This method:
      # - Normalizes CRS
      # - Classifies features into semantic layers
      # - Creates overlay layers when needed (points)
      #
      # @param path [String] path to GeoJSON file
      # @return [void]
      def add_geojson(path)
        features = LayerGeoJSON.load(path)

        features.each do |feature|
          maybe_create_line_label(feature)

          case feature.layer
          when :water
            kind =
              case (feature.properties["objeto"] || feature.properties["waterway"]).to_s.downcase
              when /river|río|canal/	then :river
              when /stream|arroyo/	then :stream
              else :minor
              end

            @layers[:water] << [kind, feature]

          when :roads
            @layers[:street] << feature

          when :parks
            @layers[:park] << feature

          when :track
            @layers[:track] << feature
          else
            geom_type = feature.geometry["type"]

            if geom_type == "Point"
              points_style = @style.points || begin
                warn "Style error: missing 'points' section"
              end

              font = @style.points[:font] || begin
                warn "[libgd-gis] points.font not defined in style, using random system font"
                GD::GIS::FontHelper.random
              end

              size = @style.points[:size] || begin
                warn "[libgd-gis] points.font size not defined in style, using random system font size"
                (6..14).to_a.sample
              end

              color = @style.points[:color] ? @style.normalize_color(@style.points[:color]) : GD::GIS::ColorHelpers.random_vivid
              font_color = @style.points[:font_color] ? @style.normalize_color(@style.points[:font_color]) : [250, 250, 250, 0]

              icon  = if @style.points.key?(:icon_fill) && @style.points.key?(:icon_stroke)
                        [points_style[:icon_stroke],
                         points_style[:icon_stroke]]
                      end
              icon  = points_style.key?(:icon) ? points_style[:icon] : nil if icon.nil?

              @points_layers << GD::GIS::PointsLayer.new(
                [feature],
                lon:   ->(f) { f.geometry["coordinates"][0] },
                lat:   ->(f) { f.geometry["coordinates"][1] },
                icon:  icon,
                label: ->(f) { f.properties["name"] },
                font:  font,
                size:  size,
                color: color,
                font_color: font_color,
                symbol: @count
              )
              @count += 1
            elsif LINE_GEOMS.include?(geom_type)
              @layers[:minor] << feature
            end
          end
        end
      end

      # Adds a single point (marker) to the map.
      #
      # This is a convenience helper for the most common use case: rendering
      # one point with an optional label and icon, without having to build
      # a full collection or manually configure a PointsLayer.
      #
      # Internally, this method wraps the given coordinates into a one-element
      # data collection and delegates rendering to {GD::GIS::PointsLayer},
      # preserving the same rendering behavior and options.
      #
      # This method is intended for annotations, markers, alerts, cities,
      # or any scenario where only one point needs to be rendered.
      #
      # @param lon [Numeric]
      #   Longitude of the point.
      # @param lat [Numeric]
      #   Latitude of the point.
      # @param label [String, nil]
      #   Optional text label rendered next to the point.
      # @param icon [String, Array<GD::Color>, nil]
      #   Marker representation. Can be:
      #   - a path to an image file
      #   - :numeric or :alphabetic symbol styles
      #   - an array of [fill, stroke] colors
      #   - nil to generate a default marker
      # @param font [String, nil]
      #   Font path used to render the label or symbol.
      # @param size [Integer]
      #   Font size in pixels (default: 12).
      # @param color [Array<Integer>]
      #   Label or symbol background color as an RGB(A) array.
      # @param font_color [GD::Color, nil]
      #   Text color for numeric or alphabetic symbols.
      #
      # @return [void]
      #
      # @example Render a simple point
      #   map.add_point(
      #     lon: -58.3816,
      #     lat: -34.6037
      #   )
      #
      # @example Point with label
      #   map.add_point(
      #     lon: -58.3816,
      #     lat: -34.6037,
      #     label: "Buenos Aires"
      #   )
      #
      # @example Point with numeric marker
      #   map.add_point(
      #     lon: -58.3816,
      #     lat: -34.6037,
      #     icon: "numeric",
      #     label: "1",
      #     font: "/usr/share/fonts/DejaVuSans.ttf"
      #   )
      #

      def add_point(
        lon:,
        lat:,
        label: nil,
        icon: nil,
        font: nil,
        size: nil,
        color: nil,
        font_color: nil,
        symbol: nil
      )
        row = {
          lon: lon,
          lat: lat,
          label: label
        }

        @points_layers << GD::GIS::PointsLayer.new(
          [row],
          lon: ->(r) { r[:lon] },
          lat: ->(r) { r[:lat] },
          icon: icon || @style.point[:icon],
          label: label ? ->(r) { r[:label] } : nil,
          font: font || @style.point[:font],
          size: size || @style.point[:size],
          color: color || @style.point[:color],
          font_color: font_color || @style.point[:font_color],
          symbol: symbol
        )
      end

      # Adds a generic points overlay layer.
      #
      # @param data [Enumerable]
      # @param opts [Hash]
      # @return [void]
      def add_points(data, **)
        @points_layers << GD::GIS::PointsLayer.new(data, **)
      end

      # Adds a generic lines overlay layer.
      #
      # @param features [Array]
      # @param opts [Hash]
      # @return [void]
      def add_lines(features, **)
        @lines_layers << GD::GIS::LinesLayer.new(features, **)
      end

      # Adds a generic polygons overlay layer.
      #
      # @param polygons [Array]
      # @param opts [Hash]
      # @return [void]
      def add_polygons(polygons, **)
        @polygons_layers << GD::GIS::PolygonsLayer.new(polygons, **)
      end

      # Renders the map.
      #
      # Chooses between tile rendering and viewport rendering
      # depending on whether width and height are set.
      #
      # @return [void]
      # @raise [RuntimeError] if style is not set
      def render
        raise "map.style must be set" unless @style

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

        # 1. GeoJSON semantic layers
        @style.order.each do |kind|
          draw_layer(kind, projection)
        end

        # 2. Generic overlays
        @polygons_layers.each { |l| l.render!(@image, projection) }
        @lines_layers.each    { |l| l.render!(@image, projection) }
        @points_layers.each   { |l| l.render!(@image, projection) }

        draw_legend
      end

      def render_viewport
        raise "map.style must be set" unless @style

        @image = GD::Image.new(@width, @height)
        @image.antialias = false

        # 1. Compute global pixel bbox
        min_lng, min_lat, max_lng, max_lat = @bbox

        x1, y1 = GD::GIS::Projection.lonlat_to_global_px(min_lng, max_lat, @zoom)
        GD::GIS::Projection.lonlat_to_global_px(max_lng, min_lat, @zoom)

        # 2. Fetch tiles
        tiles, = @basemap.fetch_tiles

        # 3. Draw tiles clipped to viewport
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

        # 4. Projection (viewport version)
        projection = lambda do |lon, lat|
          GD::GIS::Geometry.project(lon, lat, @bbox, @zoom)
        end

        # 5. REUSE the same render pipeline
        @style.order.each do |kind|
          draw_layer(kind, projection)
        end

        @polygons_layers.each { |l| l.render!(@image, projection) }
        @lines_layers.each    { |l| l.render!(@image, projection) }
        @points_layers.each   { |l| l.render!(@image, projection) }

        draw_legend
      end

      # Saves the rendered image to disk.
      #
      # @param path [String]
      # @return [void]
      def save(path)
        @image.save(path)
      end

      # Draws a semantic feature layer.
      #
      # @param kind [Symbol]
      # @param projection [#call]
      # @return [void]
      def draw_layer(kind, projection)
        items = @layers[kind]
        return if items.nil? || items.empty?

        style =
          case kind
          when :street, :primary, :motorway, :secondary, :minor
            @style.roads[kind]
          when :track
            @style.track[kind]
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

            if POLY_GEOMS.include?(geom)
              f.draw(@image, projection, nil, nil, style)
            elsif style[:stroke]
              r, g, b, a = style[:stroke]
              a = 0 if a.nil?
              color = GD::Color.rgba(r, g, b, a)

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
