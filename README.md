# example-rails6

## Setup
```
DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build
docker-compose up -d
```

For development on Mac, not in docker
```
cd app
bundle install --jobs=8 --retry=3 --path=vendor/bundle
yarn install --check-files
```

## Action Cable
ref. https://qiita.com/eRy-sk/items/4c4e983e34a44c5ace27

1. モデルの作成
```
bundle exec rails g model message content:text
bundle exec rails db:migrate
```

2. コントローラの作成
```
bundle exec rails g controller rooms show
```

3. アクションの処理を追加
```
# app/controllers/rooms_controller.rb
class RoomsController < ApplicationController
  def show
    @messages = Message.all
  end
end
```

4. ビューの作成
```
# app/views/rooms/show.html.erb
<h1>Chat room</h1>
<div id='messages'>
  <%= render @messages %>
</div>
```

5. パーシャルの作成
```
# app/views/messages/_message.html.erb
<div class='message'>
  <p><%= message.content %></p>
</div>
```

6. データの登録
```
docker-compose exec rails bundle exec rails c
irb(main):001:0> Message.create! content: 'Hello'
```

7. チャネルの作成
```
yarn add jquery
```

```
# config/webpack/environment.js
const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.append('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

module.exports = environment
```

```
# app/javascript/packs/application.js
:
require('jquery')
```
