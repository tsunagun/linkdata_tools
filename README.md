## 概要

LinkData.jpで公開されているテーブルデータ（テキスト形式）から，MetaBridge登録用の簡易DSPを生成する．


## 実行例

    ruby lib/link_data.rb http://ja.linkdata.org/work/rdf1s531i#work_information

## 残っている課題

* '''記述項目のプロパティURIが与えられていない場合に，記述項目名から補完する'''
    * 現在はプロパティURIが空白になっている
* 記述項目の項目名が与えられていない場合に，プロパティURIから補完する
    * 現在はプロパティURIの末尾（スラッシュあるいはハッシュ以降）を項目名として使用
        * http://purl.org/dc/terms/title => title
        * http://www.w3.org/1999/02/22-rdf-syntax-ns#value => value
* 記述項目の最小出現数を適切に与える
    * 現在は１に固定している
* 記述項目の値制約を適切に与える
    * 現在は"文字列"に固定している


## 注意
* 動作確認はruby 1.9.3-p362, MacOSX 10.8で行っています
* HTML/XMLパーサ「Nokogiri」を使用しています．インストールしていない場合は，`gem install nokogiri` を実行してインストールしてください．
** Nokogiriのインストールには「LibXML2」が必要です．aptitudeやhomebrewなど，各種パッケージ管理ツールでインストールしてください．
* 処理に数十秒かかることがあります．
** LinkDataのプロパティは，URIあるいはURI以外の文字列で指定されます．
** URIが指定された場合，簡易DSP用の記述項目名を取得するために，プロパティURIごとにMetaBridgeへのアクセスを行っています．
*** ./lib/string.rb の def to_label を参照
** MetaBridgeへの負荷を抑えるため，HTTPリクエスト送信前に1秒待機するようにしています．
** sleep 1 を変更すれば，待機時間を無くしたり延ばしたりすることが可能です．
