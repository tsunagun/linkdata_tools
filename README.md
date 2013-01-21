## 概要

LinkData.jpで公開されているテーブルデータ（テキスト形式）から，MetaBridge登録用の簡易DSPを生成する．

## 実行例

    ruby main.rb http://ja.linkdata.org/download/rdf1s531i/link/Pre_Socratic_philosophy.txt

    ruby main.rb src/Pre_Socratic_philosophy.txt

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
