<div class="doc-header">

  <div class="nav-left">
    <img src="../images/logo-gis.png" class="nav-logo"/>
    <span class="nav-title">libgd-gis</span>
  </div>

  <div class="doc-nav">
    <a href="index.html">← Documentation Index</a>
  </div>

  <div class="doc-lang">
    <strong>Language:</strong>
    <a href="../en/index.md">🇬🇧 EN</a>
    <a href="../es/index.md">🇪🇸 ES</a>
    <a href="jp/index.md">🇯🇵 JP</a>
  </div>

</div>


# libgd-gis — Ruby向け静的マップレンダリング

`libgd-gis` は **Ruby向けの静的GISレンダリングエンジン** です。  
**ruby-libgd** と GD Graphics Library 上に構築されています。

GeoJSON や座標データを  
**高品質なラスター画像** に変換します。

インタラクティブマップではありません。  
**レンダリングエンジン** です。

---

## レンダリングパイプライン

1. ビューポートと bounding box を定義
2. ベースマップを読み込み
3. YAML スタイルを適用
4. 地理レイヤーを追加
5. マップをレンダリング
6. ruby-libgd で後処理

---

## ビューポートとマップ設定

| ファイル | 説明 |
|---------|------|
| [`new.md`](new.md) | 範囲、ズーム、画像サイズ設定 |

---

## スタイル (YAML)

| ファイル | 説明 |
|---------|------|
| [`styles.md`](styles.md) | YAML スタイル定義 |

---

## GeoJSON レイヤー

| ファイル | 説明 |
|---------|------|
| [`add_geojson.md`](add_geojson.md) | GeoJSON レンダリング |

---

## オーバーレイ

| ファイル | 説明 |
|---------|------|
| [`add_points.md`](add_points.md) | ポイントとラベル |
| [`add_lines.md`](add_lines.md) | ライン描画 |
| [`add_polygons.md`](add_polygons.md) | ポリゴン描画 |

---

## レンダリング後の画像操作

| ファイル | 説明 |
|---------|------|
| [`map_image.md`](map_image.md) | GD::Image へのアクセス |

---

## 設計思想

- GIS処理 → libgd-gis  
- 画像処理 → ruby-libgd  

---

## 安定性について

libgd-gis は急速に進化しています。

Issue:
- https://github.com/ggerman/libgd-gis/issues
- ggerman@gmail.com
