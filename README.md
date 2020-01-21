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
bundle exec rails c
irb(main):001:0> Message.create! content: 'Hello'
```

7. jQueryの追加
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

8. チャネルの作成
```
bundle exec rails g channel room speak
```

```
# app/channels/room_channel.rb
class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    ActionCable.server.broadcast 'room_channel', message: data['message']
  end
end
```

```
# app/javascript/channels/room_channel.js
consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    return alert(data['message'])
  },

  speak: function(message) {
    return this.perform('speak', {
      message: message
    })
  }
});
```

9. フォームの作成
```
# app/views/rooms/show.html.erb
<h1>Chat room</h1>
<div id='messages'>
  <%= render @messages %>
</div>

<%= label_tag :content, 'Say something:' %>
<%= text_field_tag :content, nil, data: { behavior: 'room_speaker' } %>
```

```
# app/javascript/channels/room_channel.js
const chatChannel = consumer.subscriptions.create("RoomChannel", {
  // ...
});

$(document).on('keypress', '[data-behavior~=room_speaker]', function(event) {
  if (event.keyCode === 13) {
    chatChannel.speak(event.target.value);
    event.target.value = '';
    return event.preventDefault();
  }
});
```

10. 入力文字列をDBに保存
```
# app/channels/room_channel.rb
class RoomChannel < ApplicationCable::Channel
:
  def speak(data)
    Message.create! content: data['message']
  end
```

11. ジョブの作成
```
bundle exec rails g job MessageBroadcast
```

```
# app/jobs/message_broadcast_job.rb
class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'room_channel', message: render_message(message)
  end

  private

  def render_message(message)
    ApplicationController.renderer.render partial: 'messages/message', locals: { message: message }
  end
end
```

12. モデルの編集
```
class Message < ApplicationRecord
  validates :content, presence: true
  after_create_commit { MessageBroadcastJob.perform_later self }
end
```

13. 画面に文字を表示
```
# app/javascript/channels/room_channel.js
  received(data) {
    return $('#messages').append(data['message'])
  },
```
