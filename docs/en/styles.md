# Map Styles and GeoJSON Rendering

## Styling maps with GD::GIS::Style

libgd-gis uses YAML-based style definitions to control how maps and layers are rendered.

```ruby
map.style = GD::GIS::Style.load("solarized")
```

This loads a style definition from a YAML file and applies it globally to the map.

---

## Style files (.yml)

Styles are defined using YAML files, usually located in:

```
examples/styles/
```

A style file describes how each layer should be drawn.

```yaml
roads:
  motorway:
    stroke: [88, 110, 117]
    stroke_width: 10
  primary:
    stroke: [147, 161, 161]
    stroke_width: 6
  minor:
    stroke: [203, 75, 22]
    stroke_width: 1

water:
  stroke: [38, 139, 210]
  fill: [7, 54, 66]

parks:
  fill: [42, 161, 152]
```

### Key concepts

- Top-level keys define layer categories
- Nested keys define sub-types
- Colors are RGB arrays
- Stroke and fill depend on geometry type

---

## Adding GeoJSON data

```ruby
GEOJSON = "data/home_store.geojson"
map.add_geojson(GEOJSON)
```

This parses the GeoJSON file, classifies its features, and renders them using the active style.

---

## Style-driven rendering

The same GeoJSON can be rendered with different styles without changing the data.

---

## Summary

- Styles are YAML-based
- Styles control all visual output
- GeoJSON rendering depends entirely on the active style
