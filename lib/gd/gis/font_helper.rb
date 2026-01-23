module GD
  module GIS
    # Provides helper methods for discovering and selecting font files
    # available on the local system.
    #
    # This module is primarily used to supply font paths to text-rendering
    # components (such as PointsLayer labels) in environments where font
    # availability is system-dependent.
    #
    # Font discovery is performed by scanning a set of well-known directories
    # for TrueType and OpenType font files. The results are cached for the
    # lifetime of the process.
    #
    # Supported font formats:
    # - TrueType (.ttf)
    # - OpenType (.otf)
    # - TrueType Collection (.ttc)
    #
    # @example Select a random system font
    #   font_path = GD::GIS::FontHelper.random
    #
    # @example Find a font by name fragment
    #   font_path = GD::GIS::FontHelper.find("Noto")
    #
    # @note
    #   This helper does not validate glyph coverage (e.g. CJK support).
    #   It only locates font files present on the system.
    module FontHelper
      PATHS = [
        "/usr/share/fonts",
        "/usr/local/share/fonts",
        File.expand_path("~/.fonts")
      ].freeze

      EXTENSIONS = %w[ttf otf ttc].freeze

      # Returns the list of all font files discovered on the system.
      #
      # The search is performed once and cached. Subsequent calls return
      # the cached result.
      #
      # Font files are discovered by recursively scanning the directories
      # defined in {PATHS} for files matching the extensions in {EXTENSIONS}.
      #
      # @return [Array<String>]
      #   An array of absolute file paths to font files.
      def self.all
        @all ||= PATHS.flat_map do |path|
          next [] unless Dir.exist?(path)

          EXTENSIONS.flat_map do |ext|
            Dir.glob("#{path}/**/*.#{ext}")
          end
        end.compact.uniq
      end

      # Returns a randomly selected font file from the system.
      #
      # This is primarily intended as a fallback mechanism when no explicit
      # font is configured by the caller.
      #
      # @return [String]
      #   Absolute path to a font file.
      #
      # @raise [RuntimeError]
      #   If no font files are found on the system.
      #
      # @note
      #   The selected font is not guaranteed to support any particular
      #   character set.
      def self.random
        all.sample or raise "GD::GIS::FontHelper: no fonts found on system"
      end

      # Finds a font file whose filename includes the given name fragment.
      #
      # The match is case-insensitive and performed against the basename
      # of each discovered font file.
      #
      # @param name [String]
      #   A substring to search for in font filenames (e.g. "Noto", "DejaVu").
      #
      # @return [String, nil]
      #   The path to the first matching font file, or nil if no match is found.
      def self.find(name)
        all.find do |f|
          File.basename(f).downcase.include?(name.downcase)
        end
      end
    end
  end
end
