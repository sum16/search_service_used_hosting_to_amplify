# ゴルフ場を検索できる  
  
APIモックを作成し検索の条件に沿ったデータを返すようにする
  
  
## フロント(クライアント)側  
  
フォームで入力された「日付・ゴルフ場までの所要時間」などの検索条件をもとに API へリクエストし、API から受け取った「条件に合ったゴルフ場」を一覧表示  
  

## バックエンド側（バッチ処理, Lamda/Ruby）  
1. Rakuten API で関東エリア内のゴルフ場を全て取得
2. Google Map API で、出発地点（東京駅や横浜駅）から 1 で取得したそれぞれのゴルフ場までの車での所要時間を取得
3. 1,2 の情報をセットにして DynamoDB に保存
  

## バックエンド(API Gateway/Lamda/Ruby)
1. フロント側から受け取った「日付・ゴルフ場までの所要時間」などの検索条件をもとに Rakuten API で「予約可能なゴルフ場」を取得
2. 1で取得した「予約可能なゴルフ場」とバッチ処理で DynamoDB に保存しておいた「ゴルフ場とそのゴルフ場までの所要時間」のデータを使って条件がマッチしたゴルフ場だけをフロント側へ返す  
  
## ホスティング  
AWS Amplyfy  
  
  
# 前提知識
  
```
エンドポイントとは、特定のリソースに対して与えられた固有の一意な URI のこと
```
