# マップスタイルとGeoJSON描画

## GD::GIS::Style によるスタイル設定

libgd-gis は YAML ベースのスタイル定義を使用します。

```ruby
map.style = GD::GIS::Style.load("solarized")
```

このコードは YAML スタイルを読み込み、マップ全体に適用します。

---

## スタイルファイル (.yml)

スタイルは通常次のディレクトリにあります。

```
examples/styles/
```

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

## GeoJSON の追加

```ruby
GEOJSON = "data/home_store.geojson"
map.add_geojson(GEOJSON)
```

GeoJSON は解析され、現在のスタイルで描画されます。

---

## まとめ

- スタイルは YAML で定義
- 描画はスタイルに依存
- データと見た目を分離可能
