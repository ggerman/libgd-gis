## Requisito de Estilo (Importante)

Un objeto `GD::GIS::Map` **no puede renderizarse sin un estilo asociado**.

El objeto `style` define cómo las capas semánticas (calles, agua, parques, puntos, etc.)
se transforman en atributos visuales como colores, grosores de línea, rellenos y
orden de dibujo.

Por este motivo:

- Es obligatorio asignar un estilo **antes de llamar a `map.render`**
- Intentar renderizar sin un estilo producirá un error en tiempo de ejecución
- Esta es una decisión de diseño deliberada, no un valor por defecto implícito

Ejemplo:

```ruby
map = GD::GIS::Map.new(
  bbox: PARIS,
  zoom: 13,
  basemap: :carto_light
)

map.style = GD::GIS::Style.load("default")

map.render
map.save("paris.png")
```

### ¿Por qué los estilos son obligatorios?

libgd-gis no define estilos visuales implícitos ni valores hardcodeados.

Exigir un estilo explícito garantiza que:

- el comportamiento de renderizado sea determinístico
- la semántica visual esté completamente bajo control del usuario
- no existan supuestos ocultos sobre colores o capas
- las definiciones de estilo puedan versionarse, revisarse y mantenerse

Esta restricción aplica tanto al modo de renderizado por tiles
como al modo de viewport.
