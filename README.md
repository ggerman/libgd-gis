# LibGD-GIS

<p align="center">
  <a href="https://rubystacknews.com/2026/01/07/ruby-can-now-draw-maps-and-i-started-with-ice-cream/">
    <img src="https://img.shields.io/badge/RubyStackNews-CC342D?style=for-the-badge&logo=ruby&logoColor=white" />
  </a>
  <a href="https://x.com/ruby_stack_news">
    <img src="https://img.shields.io/badge/Twitter%20@RubyStackNews-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" />
  </a>
  <a href="https://www.linkedin.com/in/germ%C3%A1n-silva-56a12622/">
    <img src="https://img.shields.io/badge/Germán%20Silva-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" />
  </a>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/libgd-gis">
    <img src="https://img.shields.io/badge/RubyGems-libgd--gis-CC342D?style=for-the-badge&logo=rubygems&logoColor=white" />
  </a>
  <a href="https://github.com/ggerman/libgd-gis">
    <img src="https://img.shields.io/badge/GitHub-libgd--gis-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
  <a href="https://github.com/ggerman/ruby-libgd">
    <img src="https://img.shields.io/badge/Engine-ruby--libgd-CC342D?style=for-the-badge&logo=ruby&logoColor=white" />
  </a>
</p>

<p align="right">
  <img src="docs/images/logo-gis.png" width="160" />
</p>

![CI](https://github.com/ggerman/libgd-gis/actions/workflows/ci.yml/badge.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6bc3e7d6118d47e6959b16690b815909)](https://www.codacy.com/app/libgd-gis/libgd-gis?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=libgd-gis/libgd-gis&amp;utm_campaign=Badge_Grade)
[![Test Coverage](https://coveralls.io/repos/githublibgd-gis/libgd-gis/badge.svg?branch=master)](https://coveralls.io/github/libgd-gis/libgd-gis?branch=master)
[![Gem Version](https://img.shields.io/gem/v/libgd-gis.svg)](https://rubygems.org/gems/libgd-gis)


| Examples | Examples | Examples |
| :----: | :----: | :--: |
| <img src="docs/examples/parana.png" height="250"> | <img src="docs/examples/nyc.png" height="250"> | <img src="docs/examples/paris.png" height="250"> |
| <img src="examples/nyc/nyc.png" height="250"> | <img src="docs/examples/tokyo_solarized.png" height="250"> | <img src="examples/parana/parana.png" height="250"> |
| <img src="docs/examples/america.png" height="250"> | <img src="docs/examples/argentina_museum.png" height="250"> | <img src="docs/examples/museos_parana.png" height="250"> |
| <img src="docs/examples/asia.png" height="250"> | <img src="docs/examples/europe.png" height="250"> | <img src="docs/examples/icecream_parana.png" height="250"> |
| <img src="docs/examples/argentina_cities.png" height="250"> | <img src="docs/examples/tanzania_hydro.png" height="250"> | <img src="docs/examples/parana_polygon.png" height="250"> |
| <img src="docs/examples/parana_carto_dark.png" height="250"> | <img src="docs/examples/ramirez_avenue.png" height="250"> | <img src="examples/paris/paris.png" height="250"> |

---

> **libgd-gis is evolving very fast**, so some examples may temporarily stop working.  
> Please report issues or ask for help — feedback is very welcome.  
> https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

--

## A geospatial raster engine for Ruby.

libgd-gis allows Ruby to render real maps, GeoJSON layers, vector features, and geospatial tiles using a native raster backend powered by **libgd**.

It restores something Ruby lost over time:
 the ability to generate **maps, tiles, and GIS-grade visualizations natively**, without relying on external tools like QGIS, Mapnik, ImageMagick, or Mapbox.

Built on top of **ruby-libgd**, this project turns Ruby into a **map rendering engine**, capable of producing spatial graphics, tiled maps, and geospatial outputs directly inside Ruby processes.

- No external renderers.
-  No shelling out.
-  Just Ruby, raster, and GIS.

---

## What is this?

`libgd-gis` is a **geospatial rendering engine** for Ruby built on top of [`ruby-libgd`](https://github.com/ggerman/ruby-libgd).

It allows you to:

- Load GeoJSON, CSV, or any dataset with coordinates  
- Fetch real basemap tiles  
- Reproject WGS84 (lat/lon) into Web Mercator  
- Render points, icons, and layers onto a raster map  
- Generate PNG maps or map tiles  

This is the same type of pipeline used by professional GIS systems — implemented in Ruby.

---

## Installation

### System dependency

`libgd-gis` depends on **libgd**, via `ruby-libgd`.

Install libgd first:

**Ubuntu / Debian**
```
sudo apt install libgd-dev
```

**macOS**
```
brew install gd
```

---

### Ruby gems

```
gem install ruby-libgd
gem install libgd-gis
```

---

## Quick Example

Render hydroelectric plants from a GeoJSON file:

```ruby
# libgd-gis is evolving very fast, so some examples may temporarily stop working.
# Please report issues or ask for help — feedback is very welcome.
# https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

require "gd/gis"
require "gd"

TOKYO = [139.68, 35.63, 139.82, 35.75]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :esri_satellite
)

map.style = GD::GIS::Style.load("solarized")

map.add_geojson("railways.geojson")
map.add_geojson("parks.geojson")
map.add_geojson("wards.geojson")

map.render
map.save("tokyo.png")

# --------------------------
# Overlay label
# --------------------------

img = GD::Image.open("tokyo.png")

font = "../fonts/DejaVuSans-Bold.ttf"
text = "TOKYO"

x = 24
y = 24
w = 240
h = 64

# Fondo
img.filled_rectangle(x, y, x + w, y + h, [0,0,0])

# Texto
img.text(
  text,
  x: x + 24,
  y: y + 44,
  size: 32,
  color: [255,255,255],
  font: font
)

img.save("tokyo.png")


```
---
## Animations & Tracking (Alpha)

libgd-gis is designed not only for static map rendering, but also with a strong focus on
map manipulation and animated outputs.

One of its main goals is to enable animated map generation, including:

- Route and track visualization
- Step-by-step geospatial playback
- Simulated or real-time GPS tracking
- Time-based movement over geographic layers

This makes libgd-gis suitable for use cases such as real-time geolocation tracking,
mobility analysis, and geographic storytelling.

Animated map generation is already possible, including animated GIFs showing movement
across cities (e.g. Manhattan, Buenos Aires).

However, animation support is currently in **alpha (alpha-1)**.

The animation pipeline is under active development and will be released as a stable feature
only after extensive testing, performance optimization, and API stabilization.

During this phase:
- Animation-related APIs may change
- Examples may evolve
- Feedback and testing are highly encouraged

The long-term goal is to provide a reliable and deterministic geospatial animation engine,
fully integrated with the libgd-gis rendering pipeline and powered by ruby-libgd.

| Examples | Examples | Examples |
| :----: | :----: | :--: |
| <img src="docs/examples/alpha-1/nyc_car_plane_label_opt.gif" height="250"> | <img src="docs/examples/alpha-1/pacman_buenos-aires.gif" height="250"> | <img src="docs/examples/alpha-1/pacman_manhattan-1.gif" height="250"> |
| <img src="docs/examples/alpha-1/pacman_manhattan-car.gif" height="250"> | | |

---

## Features

- Real basemap tiles  
- WGS84 → Web Mercator projection  
- GeoJSON point rendering  
- CSV / JSON support  
- Icon-based symbol layers  
- Automatic bounding box fitting  
- Raster output (PNG)  

---

## License

MIT

---

## Author

Germán Silva
https://github.com/ggerman
https://rubystacknews.com
