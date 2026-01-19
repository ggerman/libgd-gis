# add_polygons — Custom Polygon Rendering

The `add_polygons` method allows you to render custom polygon overlays directly on a map,
using geographic coordinates, without requiring a GeoJSON file.

It is useful for highlighting areas, regions, or dynamically generated shapes.

---

## Basic usage

```ruby
require "gd/gis"

PARIS = [2.25, 48.80, 2.42, 48.90]

map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 10,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("dark")
```

---

## Polygon definition

Polygons are defined as an array of polygons, where each polygon may contain one or more rings.

```ruby
polygons = [
  [
    [
      [-74.01, 40.70],
      [-74.00, 40.70],
      [-74.00, 40.71],
      [-74.05, 41.02],
      [-74.01, 40.71],
      [-74.01, 40.70]
    ]
  ]
]
```

### Notes

- Coordinates must be in `[lng, lat]` order
- The first and last point must be identical to close the polygon
- Multiple polygons are supported in a single call

---

## Adding polygons to the map

```ruby
map.add_polygons(
  polygons,
  fill:   [34, 197, 94, 180],
  stroke: [16, 185, 129],
  width:  2
)
```

---

## Parameters

### `polygons` (required)

Array of polygons defined by geographic coordinates.

### `fill`

```ruby
fill: [R, G, B]
fill: [R, G, B, A]
```

Defines the polygon fill color. Alpha is optional.

### `stroke`

```ruby
stroke: [R, G, B]
```

Defines the polygon border color.

### `width`

```ruby
width: 2
```

Border width in pixels.

---

## Rendering and saving

```ruby
map.render
map.save("output/polygons.png")
```

---

## Style interaction

`add_polygons` does not rely on YAML styles.

- Styling is defined inline
- Ideal for dynamic or temporary overlays
- Fully compatible with global map styles

---

## Summary

- Render polygons without GeoJSON
- Uses `[lng, lat]` coordinates
- Supports alpha transparency
- Independent from YAML style system

![](/home/ggerman/ruby/libgd-gis.github/docs/examples/normalization/polygons.png)
