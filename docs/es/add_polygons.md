# add_polygons — Renderizado de polígonos personalizados

El método `add_polygons` permite renderizar polígonos personalizados directamente sobre el mapa,
usando coordenadas geográficas, sin necesidad de GeoJSON.

Es ideal para overlays dinámicos y áreas destacadas.

---

## Uso básico

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

## Definición de polígonos

Los polígonos se definen como un array de polígonos con uno o más anillos.

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

### Notas

- Las coordenadas deben estar en formato `[lng, lat]`
- El primer y último punto deben coincidir
- Se soportan múltiples polígonos

---

## Agregar polígonos al mapa

```ruby
map.add_polygons(
  polygons,
  fill:   [34, 197, 94, 180],
  stroke: [16, 185, 129],
  width:  2
)
```

---

## Parámetros

### `polygons`

Array de polígonos geográficos.

### `fill`

Color de relleno, con alpha opcional.

### `stroke`

Color del borde.

### `width`

Ancho del borde en píxeles.

---

## Renderizado

```ruby
map.render
map.save("output/polygons.png")
```

---

## Relación con estilos

`add_polygons` no depende de estilos YAML.

- Estilos inline
- Ideal para overlays dinámicos
- Compatible con estilos globales

---

## Resumen

- Polígonos sin GeoJSON
- Coordenadas `[lng, lat]`
- Soporte de transparencia
- Independiente del sistema de estilos
![](/home/ggerman/ruby/libgd-gis.github/docs/examples/normalization/polygons.png)