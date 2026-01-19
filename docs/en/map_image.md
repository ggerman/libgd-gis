# map.image — Accessing the Rendered Image

After rendering a map, `libgd-gis` exposes the underlying `GD::Image` instance through
`map.image`. This allows you to post-process the rendered map using the full power of
**ruby-libgd**.

This design cleanly separates:
- Geographic rendering (libgd-gis)
- Image manipulation (ruby-libgd)

---

## Basic usage

```ruby
map.render
img = map.image
```

`img` is a `GD::Image` object and supports all ruby-libgd operations.

---

## What you can do with `map.image`

Once you have access to the image, you can:

- Draw text and labels
- Add custom overlays (rectangles, lines, circles)
- Apply colors, alpha blending, and transparency
- Composite images or icons
- Save in multiple formats (PNG, JPEG, GIF)

---

## Example: adding a label after render

```ruby
img = map.image

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

## Why post-render manipulation matters

- Keeps GIS rendering deterministic
- Avoids polluting the map pipeline with presentation logic
- Enables advanced compositions and branding
- Allows reuse of ruby-libgd knowledge and tools

---

## Relationship with overlays

`map.image` complements overlay methods such as:

- `add_points`
- `add_lines`
- `add_polygons`

Use overlays for **geographic data**, and `map.image` for **pure image manipulation**.

---

## Summary

- `map.image` returns a `GD::Image`
- Full ruby-libgd API is available
- Ideal for labels, branding, and post-processing
- Clean separation between GIS and image layers

![](../examples/normalization/world_satellite_640x480 c.png)

![vintage](../examples/normalization/vintage.png)
