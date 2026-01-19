# Estilos de mapa y renderizado de GeoJSON

## Estilos con GD::GIS::Style

libgd-gis utiliza definiciones de estilo en YAML para controlar cómo se renderizan los mapas.

```ruby
map.style = GD::GIS::Style.load("solarized")
```

Esto carga un archivo de estilo YAML y lo aplica globalmente al mapa.

---

## Archivos de estilo (.yml)

Los estilos se definen en archivos YAML, normalmente ubicados en:

```
examples/styles/
```

Un archivo de estilo describe cómo debe dibujarse cada capa.

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

---

## Agregar datos GeoJSON

```ruby
GEOJSON = "data/home_store.geojson"
map.add_geojson(GEOJSON)
```

El archivo GeoJSON se parsea y se renderiza usando el estilo activo.

---

## Resumen

- Los estilos usan YAML
- Los estilos controlan la visualización
- El renderizado depende del estilo activo
