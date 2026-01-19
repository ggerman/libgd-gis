# add_points — Renderizado de puntos y POIs

El método `add_points` permite renderizar puntos (POIs, marcadores, etiquetas)
directamente sobre el mapa usando hashes u objetos Ruby, sin necesidad de GeoJSON.

Es ideal para ubicaciones, anotaciones y overlays dinámicos.

---

## Uso básico

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

## Agregar puntos al mapa

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

## Parámetros

### `pois`

Array de hashes u objetos que representan puntos.

### `lon`

Lambda para extraer la longitud.

### `lat`

Lambda para extraer la latitud.

### `label`

Texto a renderizar como etiqueta.

### `icon`

Icono opcional. Si es `nil`, se renderiza solo texto o marcador por defecto.

### `font`

Ruta absoluta a un archivo de fuente TrueType (`.ttf`).

### `size`

Tamaño de fuente en píxeles.

---

## Renderizado

```ruby
map.render
map.save("output/points.png")
```

---

## Relación con estilos

`add_points` no depende de estilos YAML.

- Estilos inline
- Control total por llamada
- Compatible con estilos globales

---

## Resumen

- Puntos sin GeoJSON
- Extracción flexible con lambdas
- Soporte de etiquetas y fuentes custom
- Independiente del sistema de estilos
