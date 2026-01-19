# add_lines — Renderizado de líneas personalizadas

El método `add_lines` permite dibujar líneas personalizadas directamente sobre el mapa,
usando coordenadas geográficas, sin necesidad de GeoJSON.

Es ideal para rutas, recorridos y trayectos dinámicos.

---

## Uso básico

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

## Definición de líneas

Las líneas se definen como un array de line strings, donde cada línea es un array
de pares `[lng, lat]`.

```ruby
lines = [
  [
    [-74.02, 40.71],
    [-74.00, 40.73],
    [-73.98, 40.75]
  ]
]
```

### Notas

- Las coordenadas deben estar en formato `[lng, lat]`
- Las líneas no necesitan cerrarse
- Se soportan múltiples líneas

---

## Agregar líneas al mapa

```ruby
map.add_lines(
  lines,
  stroke: [239, 68, 68],
  width: 3
)
```

---

## Parámetros

- `lines`: array de líneas geográficas
- `stroke`: color de la línea
- `width`: ancho de línea en píxeles

---

## Renderizado

```ruby
map.render
map.save("output/lines.png")
```

---

## Relación con estilos

`add_lines` no depende de estilos YAML.

- Estilos inline
- Ideal para overlays dinámicos
- Compatible con estilos globales

---

## Resumen

- Líneas sin GeoJSON
- Coordenadas `[lng, lat]`
- Múltiples líneas soportadas
- Independiente del sistema de estilos
