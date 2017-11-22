# 2017.11.21 12일차

### 왓챠 - 영화평점앱

```command
<ubuntu@ubuntu-xenial:/vagrant/wmovie$>
rails new watcha --skip-bundle
rails g scaffold movie title desc:text
rake db:migrate

rilas g devise:install
```

```ruby
# config > environments > development.rb
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

```command
<ubuntu@ubuntu-xenial:/vagrant/wmovie$>
rails g devise user
rake db:migrate
rake routes
```

```html
<-- app > views > layouts > application.html.erb -->
<% if user_signed_in? %>
  <%= link_to 'Logout', destroy_user_session_path, method: :delete %>
  <%= current_user.email %>님 환영합니다.
<% else %>
  <%= link_to 'Login', new_user_session_path %>
  <%= link_to 'Sign_up', new_user_registration_path %>
  <%#= link_to 'Sign_up', new_user_registration_path %> 주석처리
<% end %>
<%= link_to 'New Tweet', new_tweet_path%>

<p class="notice"><%= flash[:notice] %></p>
<p class="alert"><%= flash[:alert] %></p>
```



#### image_url

1. Carrierwave 이용

   ```ruby
   # <Gemfile>
   gem 'carrierwave', '~> 1.0'
   ```

2. ImageUploader 생성

   ```command
   <ubuntu@ubuntu-xenial:/vagrant/wmovie$>
   rails g uploader Image
   ```

   ```command
   ubuntu@ubuntu-xenial:/vagrant/wmovie$ rake db:migrate
   ```

3. movie 모델에 string, image_url 칼럼을 새로 추가.

   ```
   rails g migration add_image_url_to_movies image_url:string
   rake db:migrate
   ```

   ```ruby
   # model > movie.rb
   class Movie < ActiveRecord::Base
     mount_uploader :image_url, ImageUploader
   end
   ```

   ```ruby
   # app > controller >movies_controller.rb
   def movie_params
     params.require(:movie).permit(:title, :desc, :image_url)
   end
   ```

   ```html
   <-- _form.html.erb에 추가-->
   <div class="field">
       <%= f.label :image_url %><br>
       <%= f.file_field :image_url %><br>
   </div>
   ```

   ```html
   <-- index.html.erb에 추가 -->
   <th>Image</th>
   <td><%= image_tag movie.image_url size: 50*50 %></td>
   ```

   ```html
   <-- show.html.erb에 추가 -->
   <p>
     <strong>image:</strong><br/>
     <%= image_tag @movie.image_url %>
   </p>
   ```

   ​

4. 최종결과

   - Movie
     - title, desc, image_url

### Internalization

```ruby
# Gemfile
gem 'devise-i18n'
```

- config>initializers : app이 시작될 떄 반드시 시행되는 것. config, db file을 건드리는 경우 반드시 서버 재구동 할 것.

- config > localse > .yml[예믈] : xml을 쉽게 쓸 수 있게 만든 문서.

- config > application.rb

  - config.time_zone = 'Central Time (US & Canada)' -> comment out -> config.time_zone = 'Seoul'

  - config.i18n.default_locale = :de -> comment out -> config.i18n.default_locale = :ko

    ```command
    rails g devise:i18n:locale ko
    ```

  - config > locales > devise.views.ko.yml 생성됨 확인.

    ```command
    rails g devise:i18n:views
    ```

  - app > views > devise 폴더 생성됨 확인

  - 서버 재구동 -> 로그인, 회원가입 창 모두 한국어로 바뀐 것 확인

#### 가입인삿말 변경

- ctrl + shift + f : 전체 프로젝트 내에서 해당 키워드 검색
- '환영합니다' 검색
- 해당 인삿말 -> '가입됐다. 임마' 등으로 해당하는 인삿말로 변경.

#### user_id 추가

```command
<ubuntu@ubuntu-xenial:/vagrant/wmovie$>
rails g migration add_user_id_to_movies user_id:integer
rake db:migrate
```

#### whatcha play boxoffice crawling

- https://watcha.net/boxoffice.json

- 시작

  - require
  - login -> cookie로 해결
  - httparty & json parsing

  ```ruby
  require 'httparty'
  require 'rest-client'
  require 'json'
  require 'awesome_print'

  headers = {
  	cookie: "__uvt=; _s_guit=94029de85265a1adb5641a12eee846abf68f85633bdfb57e72b6bf4a6dd0; _ga=GA1.2.290445583.1510902299; _gid=GA1.2.729243828.1511237884; uvts=6m4WcCF3lLBbC8mz; _guinness_session=TW5vbFlsdUphNCt1U1hVT1RCc3N0L0xGSjB4OUdmZDZqVkRhWnhCU2I3N0Z4WlVsKzNycWhQTmh2d3pCVUdvWlZRTUhTQ3dwUTY3dk5aOFhhV1Z1RUE3V1JiY0JlVThPc3d2NzFGeGNvTUg3ZCtaNExLN2hLWWVjS1YrOTF5NGlxWUF3NHN4Z2pFWkl6US80cVVieGU4eFpYUTdoK2VIQ2grOCtEaG5JMWp1MCswR0xXdzRXQWY0ZW1pL1lVdkluLS1sTjBpMndlWS9rVVBQSlQ2TkxDK0xBPT0%3D--ccecf2cb1065dd2bb7cc7f28a035a271ea96ebcf"
  }
  res = HTTParty.get("https://watcha.net/boxoffice.json", :headers => headers)
  # res = RestClient.get("https://watcha.net/boxoffice.json", headers => {})
  # ap(res.body)
  watcha = JSON.parse(res.body)
  ```

- title, desc, image_url 가져오기

  ```ruby
  title = watcha['cards'][0]['items'][0]['item']['title']
  desc = watcha['cards'][0]['items'][0]['item']['interesting_comment']['text']
  image_url = watcha['cards'][0]['items'][0]['item']['poster']['medium']
  ```

- csv로 저장

  ```ruby
  CSV.open("movie_list.csv", "wb") do |csv|
  	csv << [title, image_url, desc]
  end
  ```

- 배열을 돌면서 list로 가져오기

  ```ruby
  list.each do |l|
  	title = l['items'][0]['item']['title']
  	image_url = l['items'][0]['item']['poster']['large']
  	desc = l['items'][0]['item']['interesting_comment']['text']
  end
  ```

- nil class 처리

  ```ruby
  list.each do |l|
  	title = l['items'][0]['item']['title']
  	image_url = l['items'][0]['item']['poster']['large']
  	desc = l['items'][0]['item']['interesting_comment']['text'] unless l['items'][0]['item']['interesting_comment'].nil?
  end
  ```

- csv로 저장(list)

  ```ruby
  list.each do |l|
  	title = l['items'][0]['item']['title']
  	image_url = l['items'][0]['item']['poster']['large']
  	desc = l['items'][0]['item']['interesting_comment']['text'] unless l['items'][0]['item']['interesting_comment'].nil?

  	CSV.open("movie_list.csv", "a+") do |csv|
  		csv << [title, image_url, desc]
  	end
  end
  ```

  ​

### Watcha Play crawling data 넣기(DB에)

- db> seed.rb file 이용

  ```command
  rails c
  # 저장한 csv file 절대 경로 찾기
  Rails.root 
  Rails.root.join('movie_list.csv')
  Rails.root.join('app') -> app의 절대경로.
  Rails.root.join('app', 'view') -> root(이 경우 /vagrant/wmovie/app/views의 절대 경로를 찾음)
  ```

  ```ruby
  # db > seed.rb

  # This file should contain all the record creation needed to seed the database with its default values.
  # The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
  #
  # Examples:
  #
  #   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
  #   Mayor.create(name: 'Emanuel', city: cities.first)
  require csv

  CSV.foreach(Rails.root.join('movie_list.csv')) do |row|
    # ["제목", "이미지", "코멘트"]
    Movie.create(
      title: row[0],
      desc: row[1],
      remote_image_url_url: row[2])
  end
  ```

  ```command
  rake db:drop
  rake db:migrate
  rake db:seed
  ```



#### references rails model

```command
rails g model review movie:references comment:text rating:integer user:references
```

- db > migrate > create_reviews.rb / app > model > 에서 확인

```ruby
t.references :movie, index: true, foreign_key: true
t.references :user, index: true, foreign_key: true
# -> t.integer :movie_id
# -> t.integer :user_id 같은 기능의 코드 하지만 references 사용이 성능상으로도 더 나음.
```

-----------------------------

```ruby
class Review < ActiveRecord::Base
  belongs_to :movie
  belongs_to :user
end
```

```ruby
# model > movie.rb에는 직접 추가해줘야 함.(has_many :reviews)
class Movie < ActiveRecord::Base
  mount_uploader :image_url, ImageUploader
  has_many :reviews
end
```

- rails g controller reviews create

- 모든 리뷰 보여주기.

  ```html
  <% @movie.reviews.each do |review| %>
    <p>
      <%= review.rating %>
    </p>
    <p>
      <%= review.comment %>
    </p>
  <% end %>
  ```

  ​



### 별점 평균 보여주기

- 해당하는 movie에 달린 review rating들을 다 뽑아서 더한 값 / 갯수

  1. 특정 영화에 있는 모든 리뷰들을 돌면서 하나씩 더하기
  2. 리뷰를 각각 돌면서(each) rating에 담겨있는 점수를 @sum에 더한다.
  3. 누적된 값을 전체 리뷰 수로 나눠준다.

  ```ruby
  total = 0
  @movie.reviews.each do |review|
    total += review.rating
  end
  if @movie.reviews.count == 0
    @ave = 0
  else
    @avg = total.to_f/@movie.reviews.count
  end
  ```

  ​

- 함수화(model > movie.rb)

  ```ruby
  class Movie < ActiveRecord::Base
    mount_uploader :image_url, ImageUploader
    has_many :reviews

    def avg
      total = 0
      reviews.each do |review|
        total += review.rating
      end
      if reviews.count == 0
        @ave = 0
      else
        @avg = total.to_f/reviews.count
      end
    end

  end
  ```

  views > movies > show.html.erb

  ```html
  <p>
    Average : <%= @movie.avg %>
  </p>
  ```

- 짧은 코드 방법

  ```html
  views > movies > show.html.erb
  <p>
    Average : <%= @movie.reviews.average(:rating)%>
  </p>
  ```

  ​

  ​