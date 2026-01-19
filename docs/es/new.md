# Configuración del viewport y bounding box

Esta sección describe cómo definir el viewport y el tamaño final de la imagen al renderizar mapas con **libgd-gis**.

## Caso 1: Conocés el tamaño final del mapa

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

## Caso 2: Ajustar automáticamente el mapa a un GeoJSON

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

## Caso 3: Generar un mapa desde un punto con radio

```ruby
STORE = [-60.69128666, -31.64296384]

bbox = GD::GIS::Geometry.bbox_around_point(
  STORE[0],
  STORE[1],
  radius_km: 0.5
)
```

## Notas

`width` y `height` son opcionales. Si no se especifican, el tamaño se calcula automáticamente.

![Vintage](../examples/normalization/vintage.png)