# CHANGELOG

## [0.4.2] - 2026-02-20

### Added

- Global geographic extents dataset (`extents_global.json`) including continents and countries (WGS84 bounding boxes)
- Support for using named regions as `bbox` values (e.g. `:world`, `:europe`, `:argentina`)
- Lazy-loaded `GD::GIS::Extents` module for resolving symbolic bounding boxes
- Ability to access extents via `GD::GIS::Extents.fetch` and `GD::GIS::Extents[]`
- New JSON-backed data storage for geographic extents

### Improved

- Developer experience for quick map rendering without manually specifying coordinates
- Simplified API for demos, tests, and rapid prototyping

### Notes

- Bounding boxes are approximate and intended for visualization purposes
- Coordinates use WGS84 (EPSG:4326) longitude/latitude order

## MultiLineString Example

### v0.3.2
- Updated example to align with core stylesheet changes.
- Improved YAML style structure consistency with other geometry types.
- Better defaults inherited from core styles (label handling and opacity).
- Minor cleanup in stylesheet naming and comments.
- No changes to geometry rendering logic.

### v0.3.1
- Initial complete MultiLineString example.
- Demonstrates rendering of `MultiLineString` geometries from GeoJSON.
- Basic YAML stylesheet support for:
  - stroke color
  - stroke width
  - layer drawing order
- Static bounding box definition.
- PNG output suitable for documentation and testing.

---

## Points Example

### v0.3.2
- Expanded point rendering modes:
  - image icons
  - numeric markers
  - alphabetic markers
- Updated stylesheet structure to match core `points` style definition.
- Added support for `font_color` in numeric and alphabetic modes.
- Improved label defaults inherited from global core styles.
- Switched to automatic bounding box calculation from GeoJSON.
- Minor stylesheet cleanup and alignment with core style conventions.

### v0.3.1
- Initial Points example using basic icon rendering.
- YAML stylesheet support for:
  - point color
  - icon image
  - label color
- Static font configuration.
- Manual bounding box definition.


#### [v0.2.9] —✨ Added

- Full support for **GeoJSON Point features** as overlay layers.
- New **`points`** section in styles (`solarized.yml`) to configure:
  - `icon`
  - `font`
  - `size`
  - `color` (RGB, RGBA, or automatic).
- **Point labels**, configurable via style.
- Centralized color normalization via `Style#normalize_color`.
- Automatic **random vivid color** generation when no color is specified.
- Default point marker when no `icon` is provided.

#### 🔧 Changed

- GeoJSON classification now takes **geometry type** (`Point`, `LineString`, `Polygon`) into account in addition to feature properties.
- `Point` features are rendered as **overlay layers** (`PointsLayer`) instead of legacy semantic layers.
- Style handling is centralized in `Style`; layers now receive resolved values only (improved separation of concerns).

#### 🛡️ Improved

- Stricter style validation:
  - Clear exceptions are raised when required `points` keys are missing.
- More explicit error messages for better debugging and developer experience.
- Cleaner architecture between `Map`, `Style`, and rendering layers with reduced coupling.

#### 🐛 Fixed

- GeoJSON files containing only `Point` features now render correctly.
- Fixed silent failures caused by mismatches between style definitions and geometry types.
- Corrected improper calls to color helpers (`ColorHelpers`).

## [v0.2.5] — CRS, Ontology & Multi-source GIS

This release transforms libgd-gis from an OSM-only renderer into a
true multi-source GIS engine.

## ✨ Added

### CRS Normalization Layer

A CRS middleware was added so that all incoming geometries are normalized
to **CRS84 (lon,lat)** before rendering.

Supported inputs:
- `urn:ogc:def:crs:OGC:1.3:CRS84`
- `EPSG:4326`
- `EPSG:3857` (Web Mercator)

Implemented in `CRS::Normalizer` and automatically applied in `LayerGeoJSON`.

This allows loading GeoJSON from:
- OpenStreetMap
- QGIS exports
- IGN Argentina
- Any WGS84 or Mercator dataset

without breaking projection or map alignment.

### Ontology System (Semantic Layer)

A new ontology system was introduced to decouple **data source** from
**map meaning**.

Instead of reading OSM-specific tags (`waterway`, `highway`, etc),
features are now classified by semantic meaning:

:water
:roads
:parks
:rails

regardless of their source.

Implemented in:
- `Ontology` (`lib/gd/gis/ontology.rb`)
- `ontology.yml` (semantic dictionary)

Example:

| Source | Raw value        | Ontology |
| ------ | ---------------- | -------- |
| OSM    | `waterway=river` | `:water` |
| IGN    | `objeto=Canal`   | `:water` |
| QGIS   | `type=drainage`  | `:water` |

This makes it possible to mix IGN, OSM and QGIS layers in the same map.

### Official IGN Argentina Support

libgd-gis can now render Argentina’s official hydrology datasets
from the Instituto Geográfico Nacional (IGN), including:

- Rivers
- Streams
- Canals
- Drainage networks
- Delta systems

using GeoJSON exports and ontology-based classification.

## 🛠 Changed

- `LayerGeoJSON` now:
  - Detects CRS
  - Reprojects coordinates
  - Classifies features through ontology
  - Produces `Feature` objects with `feature.layer`

- The rendering pipeline now uses semantic layers instead of
source-specific tags.

## 🧠 Architecture

GeoJSON
→ CRS Normalizer
→ Ontology
→ Feature(layer)
→ Map
→ Style
→ Raster

This is the same architecture used by professional GIS systems
(QGIS, ArcGIS, Mapbox).

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
