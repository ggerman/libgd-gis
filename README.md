# LibGD GIS

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

---

**libgd-gis** is a lightweight Ruby GIS rendering library built on top of **GD**.
It renders geographic data (GeoJSON, points, lines, polygons) into raster images using Web Mercator tiles and a simple, explicit rendering pipeline.

This library is designed for **map visualization**, not for spatial analysis.

---

## Features

- Web Mercator tile rendering (OSM, CARTO, ESRI, Stamen, etc.)
- CRS normalization (CRS84, EPSG:4326, EPSG:3857, Gauss–Krüger Argentina)
- Layered rendering pipeline
- YAML-based styling
- Rule-based semantic classification (ontology)
- Points, lines, and polygons support
- No heavy GIS dependencies

---

## Non-Goals

libgd-gis intentionally does **not** aim to be:

- a spatial analysis engine
- a replacement for PostGIS / GEOS
- a full map server
- a vector tile generator

If you need projections beyond Web Mercator or topological correctness,
use a full GIS stack.

---

## Installation

Add to your Gemfile:

```ruby
gem "libgd-gis"
```

Then run:

```bash
bundle install
```

You must also have **GD** available on your system.

---

## Basic Usage

### Create a map

```ruby
require "gd/gis"

map = GD::GIS::Map.new(
  bbox: [-58.45, -34.7, -58.35, -34.55],
  zoom: 13,
  basemap: :carto_light,
  width: 1024,
  height: 768
)
```

### Load a style

```ruby
map.style = GD::GIS::Style.load("default", from: "styles")
```

### Load GeoJSON

```ruby
map.add_geojson("data/roads.geojson")
map.add_geojson("data/water.geojson")
```

### Render

```ruby
map.render
map.save("map.png")
```

---

## Styles Are Mandatory

libgd-gis requires an explicit **style definition** in order to render a map.

A `GD::GIS::Map` instance **will not render without a style**, and calling
`map.render` before assigning one will raise an error.

This is intentional.

Styles define how semantic layers (roads, water, parks, points, etc.) are mapped
to visual properties such as colors, stroke widths, fills, and drawing order.
No implicit or default styling is applied.

### Example:

```ruby
require "gd/gis"

map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("default")

map.render
```
### Example:

```yml
# styles/default.yml

roads:
  motorway:
    stroke: [255, 255, 255]
    stroke_width: 10
    fill: [60, 60, 60]
    fill_width: 6

  primary:
    stroke: [200, 200, 200]
    stroke_width: 7
    fill: [80, 80, 80]
    fill_width: 4

  street:
    stroke: [120, 120, 120]
    stroke_width: 1

rail:
  stroke: [255, 255, 255]
  stroke_width: 6
  fill: [220, 50, 50]
  fill_width: 4
  center: [255, 255, 255]
  center_width: 1

water:
  fill: [120, 180, 255]
  fill_width: 4
  stroke: [80, 140, 220]

park:
  fill: [40, 80, 40]

order:
  - water
  - park
  - street
  - primary
  - motorway
  - rail
```
This design ensures predictable rendering and makes all visual decisions explicit
and reproducible.


---


## Named geographic extents

LibGD-GIS includes a global dataset of predefined geographic areas.
You can use them directly as the `bbox` parameter.

### Example

```ruby
map = GD::GIS::Map.new(
  bbox: :argentina,
  zoom: 5,
  width: 800,
  height: 600,
  basemap: :osm
)
```
You can also use continents or regions:

```
bbox: :world
bbox: :europe
bbox: :south_america
bbox: :north_america
bbox: :asia
```

---

## CRS Support

Supported input CRS:

- CRS84
- EPSG:4326
- EPSG:3857
- EPSG:22195 (Gauss–Krüger Argentina, zone 5)

All coordinates are normalized internally to **CRS84 (lon, lat)**.

---

## License

MIT
