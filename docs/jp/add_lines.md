# add_lines — ライン描画

`add_lines` は GeoJSON を使わずに、地理座標から直接ラインを描画するためのメソッドです。

ルート、トラック、経路の可視化に適しています。

---

## 基本的な使い方

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

## ライン定義

ラインは配列として定義され、各ラインは `[lng, lat]` の配列です。

```ruby
lines = [
  [
    [-74.02, 40.71],
    [-74.00, 40.73],
    [-73.98, 40.75]
  ]
]
```

### 注意点

- 座標は `[lng, lat]` 順
- ラインを閉じる必要はありません
- 複数ラインをサポートします

---

## ラインの追加

```ruby
map.add_lines(
  lines,
  stroke: [239, 68, 68],
  width: 3
)
```

---

## パラメータ

- `lines`: ライン配列
- `stroke`: 線の色
- `width`: 線の太さ（px）

---

## 描画と保存

```ruby
map.render
map.save("output/lines.png")
```

---

## スタイルとの関係

`add_lines` は YAML スタイルに依存しません。

- インライン定義
- 動的オーバーレイ向け
- グローバルスタイルと共存可能

---

## まとめ

- GeoJSON 不要
- `[lng, lat]` 座標
- 複数ライン対応
- スタイル非依存
