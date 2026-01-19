# マップのビューポートとバウンディングボックス設定

このドキュメントでは **libgd-gis** を使ったマップ描画時の設定方法を説明します。

## ケース1: 出力サイズが決まっている場合

```ruby
BBOX_PARANA_SANTA_FE = [
  -61.05,
  -32.10,
  -60.35,
  -31.40
]

map = GD::GIS::Map.new(
  bbox: BBOX_PARANA_SANTA_FE,
  zoom: 11,
  basemap: :esri_satellite,
  width: 800,
  height: 600
)
```

## ケース2: GeoJSON に自動フィット

```ruby
GEOJSON = "data/home_store.geojson"

bbox = GD::GIS::Geometry.bbox_for_image(
  GEOJSON,
  zoom: 13,
  width: 800,
  height: 600,
  padding_px: 100
)
```

## ケース3: ポイントと半径から生成

```ruby
STORE = [-60.69128666, -31.64296384]

bbox = GD::GIS::Geometry.bbox_around_point(
  STORE[0],
  STORE[1],
  radius_km: 0.5
)
```

## 注意

`width` と `height` は省略可能です。省略時は自動計算されます。

![Vintage](../examples/normalization/vintage.png)