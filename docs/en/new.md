# Map Viewport and Bounding Box Configuration

This section explains different ways to define the viewport and final image size when rendering maps with **libgd-gis**.

## Case 1: You know the final map size

```ruby
BBOX_PARANA_SANTA_FE = [
  -61.05,
  -32.10,
  -60.35,
  -31.40
]

map = GD::GIS::Map.new(
  bbox: BBOX_PARANA_SANTA_FE,
  zoom: 11,
  basemap: :esri_satellite,
  width: 800,
  height: 600
)
```

## Case 2: Automatically fit the map to a GeoJSON

```ruby
GEOJSON = "data/home_store.geojson"

bbox = GD::GIS::Geometry.bbox_for_image(
  GEOJSON,
  zoom: 13,
  width: 800,
  height: 600,
  padding_px: 100
)
```

## Case 3: Generate a map from a point and radius

```ruby
STORE = [-60.69128666, -31.64296384]

bbox = GD::GIS::Geometry.bbox_around_point(
  STORE[0],
  STORE[1],
  radius_km: 0.5
)
```

## Notes

`width` and `height` are optional. If omitted, the engine calculates the final image size automatically.

![Vintage](../examples/normalization/vintage.png)