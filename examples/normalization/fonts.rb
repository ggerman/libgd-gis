# ruby-libgd is evolving very fast, so some examples may temporarily stop working
# Please report issues or ask for help — feedback is very welcome
# https://github.com/ggerman/ruby-libgd/issues or ggerman@gmail.com

module GD
  module Fonts
    PATHS = [
      "/usr/share/fonts",
      "/usr/local/share/fonts",
      File.expand_path("~/.fonts")
    ]

    def self.all
      @all ||= PATHS.flat_map { |p|
        Dir.glob("#{p}/**/*.{ttf,otf,ttc}")
      }.uniq
    end

    def self.random
      all.sample or raise "No fonts found"
    end

    def self.find(name)
      all.find { |f| File.basename(f).downcase.include?(name.downcase) }
    end
  end
end
