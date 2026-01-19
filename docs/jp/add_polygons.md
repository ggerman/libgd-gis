# add_polygons — ポリゴン描画

`add_polygons` は GeoJSON を使わずに、地理座標から直接ポリゴンを描画するためのメソッドです。

動的なオーバーレイや強調表示に適しています。

---

## 基本的な使い方

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

## ポリゴン定義

ポリゴンは配列として定義され、1つ以上のリングを含めることができます。

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

### 注意点

- 座標は `[lng, lat]` 順
- 最初と最後の点は同一である必要があります
- 複数ポリゴンをサポートします

---

## ポリゴンの追加

```ruby
map.add_polygons(
  polygons,
  fill:   [34, 197, 94, 180],
  stroke: [16, 185, 129],
  width:  2
)
```

---

## パラメータ

- `polygons`: ポリゴン配列
- `fill`: 塗りつぶし色（alpha 対応）
- `stroke`: 枠線色
- `width`: 枠線の太さ（px）

---

## 描画と保存

```ruby
map.render
map.save("output/polygons.png")
```

---

## スタイルとの関係

`add_polygons` は YAML スタイルに依存しません。

- インライン定義
- 動的オーバーレイ向け
- グローバルスタイルと共存可能

---

## まとめ

- GeoJSON 不要
- `[lng, lat]` 座標
- 透過対応
- スタイル非依存

![](/home/ggerman/ruby/libgd-gis.github/docs/examples/normalization/polygons.png)
