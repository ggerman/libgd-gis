<div class="doc-header">

  <div class="nav-left">
    <img src="../images/logo-gis.png" class="nav-logo" width="250" />
    <span class="nav-title">libgd-gis</span>
  </div>

  <div class="doc-nav">
    <a href="index.html">← Documentation Index</a>
  </div>

  <div class="doc-lang">
    <strong>Language:</strong>
    <a href="en/index.html">🇬🇧 EN</a>
    <a href="../es/index.html">🇪🇸 ES</a>
    <a href="../jp/index.html">🇯🇵 JP</a>
  </div>

</div>

<hr/>

# libgd-gis — Static Map Rendering for Ruby

`libgd-gis` is a **static GIS rendering engine for Ruby**, built on top of  
**ruby-libgd** and the GD Graphics Library.

It transforms **geospatial data (GeoJSON, coordinates, layers)** into  
**high-quality raster images**, with full control over styling, overlays  
and post-processing.

It is **not an interactive map library**.  
It is a **map renderer**.

---

## Rendering Pipeline

libgd-gis follows a clear and explicit rendering pipeline:

1. Define viewport and bounding box
2. Load a basemap
3. Apply a style (YAML)
4. Add geographic layers (GeoJSON or overlays)
5. Render the map
6. Post-process the image with ruby-libgd

---

## Viewport & Map Setup

| File | Description |
|------|-------------|
| [`new.md`](map_new.md) | Define bounding boxes, zoom levels, image size, and automatic fitting |

This section explains how to control **what part of the world is rendered**
and **at what resolution**.

---

## Styles (YAML)

| File | Description |
|------|-------------|
| [`styles.md`](styles.md) | YAML-based styling system for roads, water, parks, rails, points |

Styles are **declarative**, reusable, and fully separated from code.

---

## GeoJSON Layers

| File | Description |
|------|-------------|
| [`add_geojson.md`](add_geojson.md) | Load and render GeoJSON files as map layers |

---

## Overlays (Programmatic Geometry)

Overlays are **explicit geometries defined in code**, not in GeoJSON files.

| File | Description |
|------|-------------|
| [`add_points.md`](add_points.md) | Render points, POIs, labels and markers |
| [`add_lines.md`](add_lines.md) | Render routes, tracks and line strings |
| [`add_polygons.md`](add_polygons.md) | Render polygons and areas with fill and alpha |

---

## Post-Render Image Access

| File | Description |
|------|-------------|
| [`map_image.md`](map_image.md) | Access the rendered `GD::Image` and manipulate it |

After rendering, the map becomes a `GD::Image` and can be modified using
the full ruby-libgd API.

---

## Design Philosophy

- Geospatial logic → libgd-gis  
- Image manipulation → ruby-libgd  

---

## Stability Notice

libgd-gis evolves quickly.

Please report issues:
- https://github.com/ggerman/libgd-gis/issues
- ggerman@gmail.com
