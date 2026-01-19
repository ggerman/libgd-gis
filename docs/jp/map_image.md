# map.image — レンダリング後の画像アクセス

マップをレンダリングした後、`libgd-gis` は `map.image` を通して
内部の `GD::Image` オブジェクトを公開します。

これにより **ruby-libgd** のすべての機能を使った後処理が可能になります。

---

## 基本的な使い方

```ruby
map.render
img = map.image
```

`img` は `GD::Image` オブジェクトです。

---

## `map.image` でできること

- テキストやラベル描画
- カスタムオーバーレイ追加
- 透過・アルファ合成
- 画像やアイコンの合成
- PNG / JPEG / GIF 保存

---

## 例: レンダリング後にラベルを追加

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

## 後処理が重要な理由

- GIS レンダリングを純粋に保つ
- 表示ロジックを分離
- 高度な合成やブランディングが可能
- ruby-libgd の知識を再利用

---

## オーバーレイとの関係

`map.image` は以下のメソッドと補完関係にあります:

- `add_points`
- `add_lines`
- `add_polygons`

地理データはオーバーレイ、画像処理は `map.image` を使用します。

---

## まとめ

- `map.image` は `GD::Image` を返す
- ruby-libgd の全機能が使用可能
- ラベルや装飾に最適
- GIS と画像処理を分離

![](../examples/normalization/world_satellite_640x480 c.png)

![vintage](../examples/normalization/vintage.png)