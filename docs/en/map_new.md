# GD::GIS::Map.new

This document describes how to initialize and use `GD::GIS::Map.new`, with a focus on the **map/image creation pipeline**, the **default tile-based rendering mode**, and the **optional viewport-based mode**.

---

## Overview

`GD::GIS::Map` is the main entry point for generating raster maps with **libgd-gis**.

It supports **two rendering modes**:

1. **Tile-based mode** (default, stable)
2. **Viewport-based mode** (opt-in)

Both modes use the same constructor. The active mode is determined solely by whether `width` and `height` are provided.

---

## Constructor Signature

```ruby
GD::GIS::Map.new(
  bbox:,
  zoom:,
  basemap:,
  width: nil,
  height: nil,
  crs: nil,
  fitted_bbox: false
)
```

---

## Parameters

### `bbox` (required)

```ruby
[min_lng, min_lat, max_lng, max_lat]
```

Defines the geographic area to render.

* Coordinates are interpreted as **WGS84 longitude/latitude** by default
* A different CRS may be specified using the `crs` parameter

Example:

```ruby
PARIS = [2.25, 48.80, 2.42, 48.90]
```

---

### `zoom` (required)

Integer zoom level following Web Mercator conventions.

Typical values:

* `10–12` → city overview
* `13–15` → streets
* `16+`   → blocks / buildings

---

### `basemap` (required)

Symbol identifying the raster tile provider used as the background layer.

The basemap affects **only the raster tiles**; vector overlays are rendered independently.

---

## Available Basemap Styles

Below is the complete list of built-in basemap identifiers supported by `GD::GIS::Basemap`.

### OpenStreetMap

| Symbol     | Description                  |
| ---------- | ---------------------------- |
| `:osm`     | Standard OpenStreetMap tiles |
| `:osm_hot` | Humanitarian style (HOT)     |
| `:osm_fr`  | OpenStreetMap France         |

---

### CARTO

| Symbol                  | Description                |
| ----------------------- | -------------------------- |
| `:carto_light`          | Light theme with labels    |
| `:carto_light_nolabels` | Light theme without labels |
| `:carto_dark`           | Dark theme with labels     |
| `:carto_dark_nolabels`  | Dark theme without labels  |

---

### ESRI / ArcGIS

| Symbol            | Description                                 |
| ----------------- | ------------------------------------------- |
| `:esri_satellite` | World Imagery (satellite)                   |
| `:esri_hybrid`    | Satellite imagery (same tiles as satellite) |
| `:esri_streets`   | World Street Map                            |
| `:esri_terrain`   | World Topographic Map                       |

Note: `:esri_satellite` and `:esri_hybrid` currently resolve to the same tile service.

---

### Stamen

| Symbol               | Description                 |
| -------------------- | --------------------------- |
| `:stamen_toner`      | High-contrast black & white |
| `:stamen_toner_lite` | Reduced-detail toner        |
| `:stamen_terrain`    | Terrain-focused map         |
| `:stamen_watercolor` | Artistic watercolor style   |

---

### Other Providers

| Symbol       | Description               |
| ------------ | ------------------------- |
| `:topo`      | OpenTopoMap               |
| `:wikimedia` | Wikimedia OSM tiles       |
| `:railway`   | OpenRailwayMap            |
| `:cyclosm`   | CyclOSM (cycling-focused) |

---

### Invalid Basemap

If an unknown symbol is provided, map initialization will fail with:

```text
Unknown basemap style
```

---

### `width` / `height` (optional, must be provided together)

When omitted, the map operates in **tile-based mode**.

When both are provided, the map operates in **viewport-based mode**.

```ruby
width: 800,
height: 600
```

---

### `crs` (optional)

Specifies the Coordinate Reference System of the input data.

Supported values:

* `"urn:ogc:def:crs:OGC:1.3:CRS84"` (default)
* `"EPSG:4326"` (lat/lon axis order)
* `"EPSG:3857"` (Web Mercator meters)
* `"EPSG:22195"` (Gauss–Krüger Argentina, zone 5)

If provided, all coordinates are normalized internally to **WGS84 (lon, lat)**.

---
## Style Requirement (Important)

A `GD::GIS::Map` **cannot be rendered without an associated style**.

The `style` object defines how semantic layers (roads, water, parks, points, etc.)
are converted into visual attributes such as colors, stroke widths, fills, and
rendering order.

For this reason:

- A style **must be assigned** before calling `map.render`
- Rendering without a style will raise a runtime error
- This is a deliberate design decision, not a default fallback

Example:

```ruby
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("default")

map.render
map.save("paris.png")
```

### Example

style/default.yml

```yml
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

> Why styles are mandatory
>
> libgd-gis does not provide implicit or hard-coded visual defaults.
> Requiring an explicit style ensures that:
> rendering behavior is deterministic
> visual semantics are fully controlled by the user
> no hidden assumptions are made about colors or layers
> style definitions remain versioned, reviewable, and explicit
> This constraint applies to both tile-based and viewport-based rendering modes.
>

---

## Rendering Modes

### 1. Tile-based Mode (Default)

Activated when `width` and `height` are **not** provided.

```ruby
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)
```

**Characteristics:**

* Output size is derived from the number of tiles
* Dimensions are multiples of `256 × 256`
* Basemap tiles define the pixel origin
* Stable and backward-compatible
* Recommended for most use cases

---

### 2. Viewport-based Mode (Opt-in)

Activated when both `width` and `height` are provided.

```ruby
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light,
  width: 800,
  height: 600
)
```

**Characteristics:**

* Output image has an exact pixel size
* BBox is recalculated to match the aspect ratio
* Geometry projection is relative to the viewport bbox
* Suitable for thumbnails, animations, and video frames

---

## Internal Behavior (Conceptual)

### CRS Normalization

If `crs` is provided, normalization happens once at initialization:

```text
Input CRS → WGS84 (lon, lat)
```

All subsequent operations assume WGS84 coordinates.

---

### Final Bounding Box Resolution

* Tile-based mode → original bbox is preserved
* Viewport-based mode → bbox is recalculated using:

```ruby
GD::GIS::Geometry.viewport_bbox
```

The resulting bbox becomes the **single source of truth** for:

* Basemap tile selection
* Geometry projection
* Rendering

---

## Minimal Example

```ruby
map = GD::GIS::Map.new(
  bbox: [2.25, 48.80, 2.42, 48.90],
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("default", from: "styles")

map.render
map.save("paris.png")
```

---

## Key Rules

* `bbox` is always geographic, never pixel-based
* `zoom` controls scale, not image size
* `width` / `height` affect output size only in viewport mode
* Basemap and vector layers always share the same final bbox

---

## Status

* Tile-based mode: **stable**
* Viewport-based mode: **opt-in / evolving**

---

This document reflects the current behavior of `GD::GIS::Map.new` after the viewport rendering and CRS normalization work.


![Vintage](../examples/normalization/vintage.png)