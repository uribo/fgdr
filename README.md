
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fgdr <img src="man/figures/logo.png" align="right" width="120px" />

(Sorry, English version of README is not availavle for
now.)

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/fgdr)](https://cran.r-project.org/package=fgdr)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/fgdr?color=FF5254)](https://cran.r-project.org/package=fgdr)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-3.3.0-blue.svg)](https://cran.r-project.org/)

[![Travis build
status](https://travis-ci.org/uribo/fgdr.svg?branch=master)](https://travis-ci.org/uribo/fgdr)
[![Codecov test
coverage](https://codecov.io/gh/uribo/fgdr/branch/master/graph/badge.svg)](https://codecov.io/gh/uribo/fgdr?branch=master)

このパッケージは、国土地理院 基盤地図情報 (**FGD**: Fundermental Geographic Data
<https://fgd.gsi.go.jp/download/menu.php>)
からダウンロードしたデータ(バージョン4.1に対応)をR上で扱うためにデータの変換を行う関数を提供します。

## Installation

パッケージのインストールは、CRANから行います。

``` r
install.packages("fgdr")
```

開発版を利用する場合はGitHub経由でインストールします。

``` r
install.packages("remotes")
remotes::install_github("uribo/fgdr")
```

## Example

fgdrパッケージを使った、基盤地図情報データの読み込み方法を紹介します。

なお、fgdrパッケージでは、基盤地図情報のデータをダウンロードする関数は用意していません。読み込むデータは各自でダウンロードしてください。また、読み込んだデータの扱いについても[基盤地図情報ダウンロードサービスの利用規約](https://fgd.gsi.go.jp/download/terms.html)に従ってください。

このパッケージには、基盤地図情報データダウロードサービスが提供している

  - 基本項目
  - 数値標高モデル (5m,
10mメッシュ)

について、データフレーム、Rの地理空間データを扱うためのクラスである[sf](https://CRAN.R-project.org/package=sf)または[raster](https://CRAN.R-project.org/package=raster)
([stars](https://github.com/r-spatial/stars))として返却する関数が備わっています。

``` r
library(fgdr)
library(raster)
library(sf)
```

## 基本項目

基本項目のデータは`read_fgd()`で読み込みます。この関数は対象のファイルの種類に応じて、自動的に地物の種類を判別して返却します。例えば、行政区画代表点
(AdmPt) では下記のようにポイントデータです。

``` r
read_fgd("FG-GML-523346-AdmPt-20180701-0001.xml")
```

    #> Simple feature collection with 4 features and 8 fields
    #> geometry type:  POINT
    #> dimension:      XY
    #> bbox:           xmin: 133.7835 ymin: 35.00697 xmax: 133.8736 ymax: 35.06013
    #> CRS:            EPSG:6668
    #> # A tibble: 4 x 9
    #>   gml_id type  name  adm_code life_span_from development_date org_gi_level
    #>   <chr>  <chr> <chr> <chr>    <date>         <date>                  <int>
    #> 1 K6_48… 郡市・東… 真庭市… 33214    2015-05-25     2018-07-03              25000
    #> 2 K6_48… 町村・指… 美咲町… 33666    2015-05-25     2018-07-03              25000
    #> 3 K6_48… 郡市・東… 津山市… 33203    2015-05-25     2018-07-03              25000
    #> 4 K6_48… 郡市・東… 津山市… 33203    2015-05-25     2018-07-03              25000
    #> # … with 2 more variables: visibility <chr>, geometry <POINT [°]>

水域 (WL) はライン、行政区画 (AdmArea) はポリゴンデータになります。

``` r
read_fgd("FG-GML-523346-AdmArea-20180701-0001.xml")
```

    #> Simple feature collection with 4 features and 8 fields
    #> geometry type:  POLYGON
    #> dimension:      XY
    #> bbox:           xmin: 133.75 ymin: 35 xmax: 133.875 ymax: 35.08333
    #> CRS:            EPSG:6668
    #> # A tibble: 4 x 9
    #>   gml_id type  name  adm_code life_span_from development_date org_gi_level
    #>   <chr>  <chr> <chr> <chr>    <date>         <date>                  <int>
    #> 1 K4_52… 町村・指… 美咲町… 33666    2018-07-02     2018-07-03              25000
    #> 2 K4_52… 郡市・東… 真庭市… 33214    2018-07-02     2018-07-03              25000
    #> 3 K4_52… 郡市・東… 津山市… 33203    2018-07-02     2018-07-03              25000
    #> 4 K4_52… 郡市・東… 津山市… 33203    2018-07-02     2018-07-03              25000
    #> # … with 2 more variables: visibility <chr>, geometry <POLYGON [°]>

## 数値標高モデル

標高のメッシュデータである数値標高モデル(DEM)
のデータはデータフレームまたはrasterとして読み込みます。対象のファイルが保存されているパスおよび数値標高データの種類を指定した`read_fgd_dem()`実行します。

### 5mメッシュ

``` r
read_fgd_dem("FG-GML-5135-63-00-DEM5A-20161001.xml", 
             resolution = 5)
```

    #> # A tibble: 33,750 x 2
    #>    type       value
    #>    <chr>      <dbl>
    #>  1 データなし    NA
    #>  2 データなし    NA
    #>  3 データなし    NA
    #>  4 データなし    NA
    #>  5 データなし    NA
    #>  6 データなし    NA
    #>  7 データなし    NA
    #>  8 データなし    NA
    #>  9 データなし    NA
    #> 10 データなし    NA
    #> # … with 33,740 more rows

デフォルトでは返り値のオブジェクトがデータフレームですが、これは引数`return_class
=`によりrasterを選ぶことも可能です。rasterとして読み込み、可視化する例を示します。

``` r
r <- 
  read_fgd_dem("FG-GML-5135-63-00-DEM5A-20161001.xml", 
             resolution = 5,
             return_class = "raster")
```

``` r
par(family = "IPAexGothic")
plot(r)
title(main = "数値標高モデル (5mメッシュ): 51356300",
      sub = "「基盤地図情報 数値標高モデル 5mメッシュ」（国土地理院）（https://fgd.gsi.go.jp/download/menu.php）\nをもとに瓜生真也(@uribo)が作成",
      cex.main = 1,
      cex.sub = 0.45,
      adj = 1)
```

<img src="man/figures/README-read_fgd_dem_raster_plot-1.png" width="100%" />

### 10mメッシュ

同様に10mメッシュのデータを読み込むには`resolution =`を10に変更してください。

``` r
read_fgd_dem("FG-GML-5440-10-dem10b-20161001.xml", 
             resolution = 10,
             return_class = "raster")
```

    #> class      : RasterLayer 
    #> dimensions : 750, 1125, 843750  (nrow, ncol, ncell)
    #> resolution : 0.0001111111, 0.00011112  (x, y)
    #> extent     : 140, 140.125, 36.08333, 36.16667  (xmin, xmax, ymin, ymax)
    #> crs        : +proj=longlat +ellps=GRS80 +no_defs 
    #> source     : memory
    #> names      : layer 
    #> values     : 5, 316  (min, max)

## ライセンス

MIT
