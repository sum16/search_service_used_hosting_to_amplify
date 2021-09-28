require 'rakuten_web_service'

module Area
  # 楽天APIで定められているエリアコード（8:茨城県,11:埼玉県,12:千葉県,13:東京都,14:神奈川県）
  # この5つのエリアを対象とします
  # 参考(楽天APIの仕様):https://webservice.rakuten.co.jp/api/areacode/golfarea.html
  CODES = ['8', '11', '12', '13', '14']
end

module Departure
  # 基準とする出発地点(今回はこの2箇所を基準となる出発地点とします)
  DEPARTURES = {
    1: '東京駅',
    2: '横浜駅'
  }
end

def duration_minutes() #出発地点と到着地点を引数にしている
  # Google Maps Platformを使って出発地点とゴルフ場の車での移動時間を出す
  gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])
  route = gmaps.directions(
    departure,
    destination,
    region: 'jp'
  )
  return unless routes.first # ルートが存在しないときはnilを返す(東京の離島など)
  duration_seconds = routes.first[:legs][0][:duration][:value]
  duration_seconds / 60
end

def put_item(course_id, durations)
  return if SearchGolfApp.find(golf_course_id: course_id) # 既にDynamoDBに同じコースIDのレコードが存在した場合は新たに保存しない
  duration = SearchGolfApp.new
  duration.golf_course_id = course_id
  duration.duration1 = durations.fetch(1)
  duration.duration2 = durations.fetch(2)
  duration.save
end

def lambda_handler(event:, context:) # バッチ処理が起動したときに最初に動くメソッド
    RaktenWebServise.cinfigure do |c|
      c.application_id = ENV['RAKUTEN_APPID']
      c.affiliate_id =  ENV['RAKUTEN_AFID']
    end

    Area::CODES.each do |code| # 全てのエリアに対して以下操作を行う #code(integerが入る)
      # このエリアのゴルフ場を楽天APIで全て取得する
    1.upto do |page| #page(integerが入る)
    courses = RaktenWebServise::Gora:Course.search(areaCode: code, page: page)
    courses.each do |course|
      course_id = course['golfCourseId']
      course_name = course['golfCourseName']
      next if course_name.include?('レッスン') # ゴルフ場以外の情報(レッスン情報)をこれでスキップしてる

      durations = {}
      Departure.DEPARTURES.each do |duration_id, departure|
        minutes = duration_minutes(departure, course_name) 
        durations.store(duration_id, minutes) if minutes
      end
      # put_item → dynamodbへputするメソッドっぽい　https://qiita.com/inouet/items/17cfbac89c5f9efe0840
      put_item(course_id, durations) unless durations.empty? # コースIDとそれぞれの出発地点とコースへの移動時間をDynamoDBへ格納する
    end
    break unless courses.next_page? # 次のページが存在するかどうか確認するメソッド(boolean) #https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/PageableResponse.html
    end

  # TODO: 2. 出発地点から取得したゴルフ場までの所要時間をGoogle Maps Platformで取得する

  # TODO: 3. 取得した取得した情報をDynamoDBに保存する
  end
  {statusCode: 200}
end


# *モジュールの使い方*

# モジュール内で定義した定数は、モジュール名を経由して呼び出すことが可能

# module Mod
#   Version = "2.3.0"
# end

# Mod::Version #=> "2.3.0"

# ----------------------------------------------------


# uptoメソッド

# 「upto」を使うと、初期値から1ずつ足していき、最大値になるまで繰り返し処理を行うことができます。変数には、初期値から最大値になるまでの数値が格納されます。

# 初期値.upto(最大値) do |変数|
#   繰り返しを行う処理
# end

# ----------------------------------------------------


# *環境変数とは*

# 環境変数は、OSが提供するデータ共有機能

# 「公開したくないデータを環境変数として定義」しておき、プログラムからデータを参照することで必要に応じて利用することが可能となる

# Rubyで設定した環境変数を読み込む方法
# ENV["キー名"]
# 例) ENV["SAMPLE"]

# ----------------------------------------------------

# ループ処理の中のnext ifは指定した条件の場合、処理をスキップする

# 例)
# for x in 1...11
#   next if x.even?  #偶数の場合true, 奇数の場合false
#   p x
# end

# ##出力結果 true(偶数)はスキップされ奇数だけが出力される
# 1
# 3
# 5
# 7
# 9


# ----------------------------------------------------

# include? メソッド

# 配列が val と == で等しい要素を持つ時に真を返します。

# 例)
# a = [ "a", "b", "c" ]
# a.include?("b")       #=> true
# a.include?("z")       #=> false


# ----------------------------------------------------


# storeメソッドとは、hashにkeyとvalueを追加するもしくはvalueを変更する際に使用するhashのメソッドの１つです。

# 引数にkeyとvalueを渡すこと使用できます。このメソッドは[]=の別名で、同じ様に使用できます。

# つまり、h[key] = valueとh.store(key,value)は、同じ操作をしていることになります。

# 例）

# #hashの初期化
# h = {}
# #keyがMike,valueが20を渡す
# h.store("Mike",20)

# ----------------------------------------------------

# emptyメソッド

# book.empty?
# description.empty?
# は、bookやdescriptionそのものは存在していることが前提で、その配列の中身が空か、文字列の中身が空の場合にtrueを返す。
# 配列や文字列そのもの（入れ物）が無い場合にはNoMethodErrorが発生する。空ですか？と聞いてるわけだから、少なくとも「入れ物」が存在しないとダメってことか。


# ----------------------------------------------------


# fetchメソッドはハッシュの値を取り出すときに便利なメソッド

# fetchメソッドは引数にハッシュのキーを指定することにより、そのキーとセットになっているバリューを取り出します。

# fetchメソッドの書き方

# hash.fetch(key)
# 基本的には「hash:[キー]」でバリューを取り出す動作と代わりありませんが、fetchでは指定したキーが存在しない場合は例外を返します。

# https://www.sejuku.net/blog/58930