# add_geojson — Renderizado de capas GeoJSON

El método `add_geojson` permite cargar y renderizar archivos GeoJSON directamente sobre el mapa.
Cada archivo GeoJSON se procesa como una capa independiente.

> **Nota**
> libgd-gis evoluciona muy rápido, por lo que algunos ejemplos pueden dejar de funcionar temporalmente.
> Reportá problemas o pedí ayuda:
> https://github.com/ggerman/libgd-gis/issues o ggerman@gmail.com

---

## Uso básico

```ruby
require "gd/gis"
require "gd"

TOKYO = [139.68, 35.63, 139.82, 35.75]

map = GD::GIS::Map.new(
  bbox: TOKYO,
  zoom: 13,
  basemap: :esri_satellite
)

map.style = GD::GIS::Style.load("solarized")

map.add_geojson("railways.geojson")
map.add_geojson("parks.geojson")
map.add_geojson("wards.geojson")

map.render
map.save("tokyo.png")
```

---

## ¿Qué hace `add_geojson`?

Cada llamada a `add_geojson`:

1. Carga el archivo GeoJSON
2. Parsea sus features
3. Clasifica las geometrías
4. Aplica el estilo YAML activo
5. Renderiza la capa según proyección y zoom

Cada GeoJSON se agrega como una capa nueva.

---

## Geometrías soportadas

- `Point`
- `MultiPoint`
- `LineString`
- `MultiLineString`
- `Polygon`
- `MultiPolygon`

El estilo define cómo se visualiza cada tipo.

---

## Orden de capas

Las capas se renderizan en el orden de carga:

```ruby
map.add_geojson("base.geojson")
map.add_geojson("overlay.geojson")
```

Las últimas capas se dibujan encima.

---

## Integración con estilos YAML

`add_geojson` depende completamente del estilo activo.

- Los tipos de geometría se mapean a secciones del estilo
- Las propiedades se usan para clasificación
- El resultado visual es 100% controlado por YAML

Ver `examples/styles/` para ejemplos.

---

## Overlays posteriores al render

Luego del render, se pueden agregar overlays manuales
utilizando `ruby-libgd`.

Ejemplo: agregar una etiqueta

```ruby
img = GD::Image.open("tokyo.png")

font = "../fonts/DejaVuSans-Bold.ttf"

img.filled_rectangle(24, 24, 264, 88, [0, 0, 0])

img.text(
  "TOKYO",
  x: 48,
  y: 68,
  size: 32,
  color: [255, 255, 255],
  font: font
)

img.save("tokyo.png")
```

---

## Resumen

- Renderizado directo de GeoJSON
- Múltiples capas soportadas
- Renderizado guiado por estilos
- El orden de capas es importante
- Compatible con overlays manuales
