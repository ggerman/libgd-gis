# add_points — Point and POI Rendering

The `add_points` method allows you to render point-based data (POIs, markers, labels)
directly on a map using Ruby hashes or objects, without requiring a GeoJSON file.

It is ideal for locations, places, annotations, and dynamic point overlays.

---

## Basic usage

```ruby
pois = [
  {
    "name" => "Home",
    "lon"  => HOME[0],
    "lat"  => HOME[1]
  }
]
```

---

## Adding points to the map

```ruby
map.add_points(
  pois,
  lon:   ->(r){ r["lon"] },
  lat:   ->(r){ r["lat"] },
  label: ->(r){ r["name"] },
  icon:  nil,
  font:  "DejaVuSans.ttf",
  size:  20
)
```

---

## Parameters

### `pois` (required)

An array of hashes or objects representing points of interest.

---

### `lon`

```ruby
lon: ->(row){ row["lon"] }
```

Lambda used to extract longitude from each record.

---

### `lat`

```ruby
lat: ->(row){ row["lat"] }
```

Lambda used to extract latitude from each record.

---

### `label`

```ruby
label: ->(row){ row["name"] }
```

Text label rendered next to the point.

---

### `icon`

```ruby
icon: nil
```

Optional icon for the point. When `nil`, only the label (or default marker) is rendered.

---

### `font`

```ruby
font: "/path/to/font.ttf"
```

Absolute path to a TrueType (`.ttf`) font file used for rendering labels.

---

### `size`

```ruby
size: 20
```

Font size in pixels.

---

## Rendering and saving

```ruby
map.render
map.save("output/points.png")
```

---

## Style interaction

`add_points` does not depend on YAML styles.

- Points are styled inline
- Labels and fonts are controlled per call
- Fully compatible with global map styles

---

## Summary

- Render points without GeoJSON
- Flexible data source via lambdas
- Supports labels and custom fonts
- Independent from YAML style system
