# 🗺️ libgd-gis 0.2.4 — Changelog

**Release date:** 2026-01-12

This release is a major step forward for libgd-gis, focused on **cartographic quality, styling, and GIS-grade rendering features**.

------

## ✨ New Features

### Styles system

libgd-gis now supports **external style definitions** to control how maps are rendered.

You can define:

- Road strokes and casings
- Water layers
- Parks, rails, and custom layers
- Label colors and font sizes

Styles can be loaded and applied at render time, enabling **themeable maps** (dark, light, carto-like, satellite overlays, etc).

------

### GeoJSON support

Full support for rendering **GeoJSON layers**:

- `Polygon`
- `MultiPolygon`
- `LineString`
- `MultiLineString`
- Feature properties are preserved for labeling and classification

This allows:

- City boundaries
- Rivers
- Roads
- Parks
- Administrative areas
- Any GIS dataset exported as GeoJSON

------

### Map image API

The new `map.image` API exposes the underlying `GD::Image` instance:

```
map.image.text(...)
map.image.rectangle(...)
map.image.filled_rectangle(...)
```

This allows custom overlays, labels, legends, watermarks, UI elements, and cartographic decorations to be drawn directly on top of the map.

------

### Label engine

A new labeling system was added:

- Labels for:
  - Routes
  - Rivers
  - Points
  - Polygons
  - Lines
- Automatic label placement
- Repeated label suppression
- Font, size, and color driven by styles

This allows producing **real map-quality annotated maps**.

------

### Points layers

Points can now be rendered from tabular or CSV-like data:

```
map.add_points(data,
  lon: ->(r) { r["lon"] },
  lat: ->(r) { r["lat"] },
  label: ->(r) { r["name"] },
  icon: "marker.png"
)
```

If `icon` is omitted, a default marker is generated automatically.

------

### Truecolor & antialiasing

Rendering now uses **truecolor images with alpha support**, enabling:

- Smooth antialiased lines
- Alpha-blended layers
- High-quality labels
- Professional cartographic output

------

## 🐛 Fixes & Improvements

- Fixed repeated labels appearing multiple times on the same feature
- Improved projection and bounding box handling
- Improved clipping of features near map borders
- Fixed polygon and multipolygon drawing issues
- Improved water layer detection and rendering
- Improved layer ordering and rendering pipeline
- Fixed CI and Docker builds for GD and pkg-config

------

## 🧪 Test & CI improvements

- Added full RSpec rendering pipeline tests
- Added point layer tests
- Added GeoJSON rendering tests
- Added CI support for libgd via apt + pkg-config
- Docker and GitHub Actions now use the same GD build path

------

## 🧩 Compatibility

- Requires **ruby-libgd ≥ 0.2.1**
- Works with Ruby 3.2 – 3.3
- Tested on Linux, Docker, and CI

------

This release transforms libgd-gis from a prototype into a **real GIS rendering engine** for Ruby:
 styles, labels, GeoJSON, points, and professional-grade map output.