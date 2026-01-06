# libgd-gis

**A geospatial raster engine for Ruby**

Render real maps, GeoJSON layers, and geospatial data directly in Ruby using a native raster backend powered by **libgd**.

This project brings back something Ruby lost over time:  
the ability to generate **maps, tiles, and geospatial visualizations natively**, without external tools like QGIS, ImageMagick, or Mapbox.

---

## 🌍 Example

This map of Tanzania was generated entirely in Ruby from a GeoJSON dataset of hydroelectric power plants:

![Tanzania hydro plants](examples/output/tanzania_hydro.png)

No JavaScript.  
No QGIS.  
No Mapbox.  
Just Ruby.

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
require "json"
require "gd/gis"

geo = JSON.parse(File.read("hydro_plants.geojson"))
plants = geo["features"]

lons = plants.map { |f| f["geometry"]["coordinates"][0] }
lats = plants.map { |f| f["geometry"]["coordinates"][1] }

bbox = [lons.min, lats.min, lons.max, lats.max]

map = GD::GIS::Map.new(
  bbox: bbox,
  zoom: 7,
  basemap: :carto_light
)

map.add_points(
  plants,
  lon: ->(f) { f["geometry"]["coordinates"][0] },
  lat: ->(f) { f["geometry"]["coordinates"][1] },
  icon: "hydro.png"
)

map.render
map.save("tanzania_hydro.png")
```

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
