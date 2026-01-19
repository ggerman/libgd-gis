# add_lines — Custom Line Rendering

The `add_lines` method allows you to draw custom line overlays on a map using
geographic coordinates, without requiring a GeoJSON file.

It is suitable for routes, paths, tracks, and any linear geometry generated at runtime.

---

## Basic usage

```ruby
require "gd/gis"

CITY = [-74.05, 40.70, -73.95, 40.80]

map = GD::GIS::Map.new(
  bbox: CITY,
  zoom: 10,
  basemap: :carto_light,
  width: 800,
  height: 800
)

map.style = GD::GIS::Style.load("light")
```

---

## Line definition

Lines are defined as an array of line strings, where each line is an array of
`[lng, lat]` coordinate pairs.

```ruby
lines = [
  [
    [-74.02, 40.71],
    [-74.00, 40.73],
    [-73.98, 40.75]
  ]
]
```

### Notes

- Coordinates must be in `[lng, lat]` order
- Lines do not need to be closed
- Multiple lines are supported in a single call

---

## Adding lines to the map

```ruby
map.add_lines(
  lines,
  stroke: [239, 68, 68],
  width: 3
)
```

---

## Parameters

### `lines` (required)

Array of line strings defined by geographic coordinates.

### `stroke`

```ruby
stroke: [R, G, B]
```

Defines the line color.

### `width`

```ruby
width: 3
```

Line width in pixels.

---

## Rendering and saving

```ruby
map.render
map.save("output/lines.png")
```

---

## Style interaction

`add_lines` does not rely on YAML styles.

- Styling is defined inline
- Ideal for dynamic overlays (routes, tracks)
- Fully compatible with global map styles

---

## Summary

- Draw lines without GeoJSON
- Uses `[lng, lat]` coordinates
- Supports multiple lines
- Independent from YAML style system

![]()
