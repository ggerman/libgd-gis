# add_points — ポイント描画とPOI

`add_points` は GeoJSON を使わずに、Ruby のデータ構造から
ポイント（POI・マーカー・ラベル）を描画するためのメソッドです。

---

## 基本的な使い方

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

## ポイントの追加

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

## パラメータ

- `pois`: ポイント配列
- `lon`: 経度取得用ラムダ
- `lat`: 緯度取得用ラムダ
- `label`: 表示テキスト
- `icon`: アイコン（省略可）
- `font`: TrueType フォントパス
- `size`: フォントサイズ（px）

---

## 描画と保存

```ruby
map.render
map.save("output/points.png")
```

---

## スタイルとの関係

`add_points` は YAML スタイルに依存しません。

- インライン定義
- 動的ポイント向け
- グローバルスタイルと共存可能

---

## まとめ

- GeoJSON 不要
- ラムダで柔軟にデータ取得
- カスタムフォント対応
- スタイル非依存
