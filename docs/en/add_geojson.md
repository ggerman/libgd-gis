# add_geojson — GeoJSON Layer Rendering

The `add_geojson` method allows you to load and render GeoJSON files directly onto a map.
Each GeoJSON file is parsed, classified, styled, and rendered as a map layer.

> **Note**
> libgd-gis is evolving very fast, so some examples may temporarily stop working.
> Please report issues or ask for help:
> https://github.com/ggerman/libgd-gis/issues or ggerman@gmail.com

---

## Basic usage

```ruby
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
```

---

## What `add_geojson` does

When calling `add_geojson`, libgd-gis:

1. Loads and parses the GeoJSON file
2. Iterates over all features
3. Classifies geometries (lines, polygons, points)
4. Applies the active YAML style
5. Renders the layer respecting projection and zoom

Each call adds a new layer on top of the previous ones.

---

## Supported geometries

- `Point`
- `MultiPoint`
- `LineString`
- `MultiLineString`
- `Polygon`
- `MultiPolygon`

Rendering behavior depends on the active style.

---

## Layer ordering

GeoJSON layers are rendered **in the order they are added**:

```ruby
map.add_geojson("base.geojson")
map.add_geojson("overlay.geojson")
```

Later layers are drawn on top of earlier ones.

---

## Styling and YAML integration

`add_geojson` relies entirely on the active `GD::GIS::Style`.

- Geometry types are mapped to style sections
- Feature properties are used for classification
- Visual output is fully style-driven

See `examples/styles/` for reference styles.

---

## Adding post-render overlays

After rendering, you can open the generated image and add custom overlays
using `ruby-libgd` directly.

Example: adding a label overlay

```ruby
img = GD::Image.open("tokyo.png")

font = "../fonts/DejaVuSans-Bold.ttf"

img.filled_rectangle(24, 24, 264, 88, [0, 0, 0])

img.text(
  "TOKYO",
  x: 48,
  y: 68,
  size: 32,
  color: [255, 255, 255],
  font: font
)

img.save("tokyo.png")
```

---

## Summary

- Load and render GeoJSON files as layers
- Multiple GeoJSON files supported
- Fully style-driven rendering
- Layer order matters
- Compatible with post-render overlays
