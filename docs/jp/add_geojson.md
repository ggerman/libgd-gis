# add_geojson — GeoJSONレイヤー描画

`add_geojson` は GeoJSON ファイルをマップ上に直接読み込み、
レイヤーとして描画するためのメソッドです。

> **注意**
> libgd-gis は非常に速いペースで進化しています。
> 問題があれば以下までご連絡ください:
> https://github.com/ggerman/libgd-gis/issues または ggerman@gmail.com

---

## 基本的な使い方

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

## `add_geojson` の動作

`add_geojson` を呼び出すと:

1. GeoJSON を読み込み
2. Feature を解析
3. ジオメトリを分類
4. YAML スタイルを適用
5. レイヤーとして描画

各 GeoJSON は独立したレイヤーとして追加されます。

---

## 対応ジオメトリ

- `Point`
- `MultiPoint`
- `LineString`
- `MultiLineString`
- `Polygon`
- `MultiPolygon`

描画方法はスタイルに依存します。

---

## レイヤー順序

レイヤーは追加順に描画されます。

```ruby
map.add_geojson("base.geojson")
map.add_geojson("overlay.geojson")
```

後から追加したものが上に描画されます。

---

## YAMLスタイルとの統合

`add_geojson` は現在の `Style` に完全に依存します。

- ジオメトリ種別でスタイルを選択
- Feature プロパティを利用
- 見た目は YAML で制御

`examples/styles/` を参照してください。

---

## 描画後のオーバーレイ

描画後、`ruby-libgd` を使って画像に直接
オーバーレイを追加できます。

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

## まとめ

- GeoJSON レイヤー描画
- 複数ファイル対応
- スタイル駆動レンダリング
- レイヤー順序が重要
- 後処理オーバーレイ対応
