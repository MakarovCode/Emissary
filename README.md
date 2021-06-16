# Emissary
Simple error catcher integrated with services like Discord and Trello, use chatbots to monitor your application and server.
Receive error catching reports to a Discord Server Channel, and use chatbots to send commands and fetch reports.

# Keynotes / Presentation
[![Watch the presentation](https://github.com/MakarovCode/Emissary/raw/main/thumb.png)](https://dms.licdn.com/playlist/C4E05AQHyxbCfCVGHYA/mp4-720p-30fp-crf28/0/1623710691404?e=1623808800&v=beta&t=gUzmyqiD7vgxfWC7KYeU53-us6buF-kf2o60RfZfxuQ)

# Features
* This tools allows you to configurate the errors or lines you want to capture from any log file, in this example you will find a configuration for catching HTTP ERROR 500.
* You can configurate the timeframes in which the logs will be read, the conditions that triggers the errores, the lines to fetch from the files, the language to markup the error to discord, characters to ignore, how often the errors fetched would be clear, and how often you want a receive reports with error ocurrences.
* You can also use chatbots to fetch and generate reports any time outside the timeframes configurated.
* You can also configurate linux commands and receive in discord the outputs or results.

# Setup your Discord Server
For this version you need a Discord server, also, you'll need to register as a developer and create an Application and a Bot

* 1. Go To [Discord Developers](https://discord.com/developers)
* 2. Create a new **application** and under the **Bot** option create a new bot
* 3. Add your new bot to your server Channel
* 4. Create a **webhook** in you server channel
* 5. Paste the **webhooks url** and chat bot token in the **Emissary** configuration file.

# Setup your Trello (Optional).
Basically you want to create or use an existing Board and List.

* 1. Go To [Trello App Key Generator](https://trello.com/app-key)
* 2. Click in **Token** to create your member token *(be aware of expiration time)*
* 3. Copy both your **public_key** and **member_token** into the initializer file or runner
* 4. Find your Trello **ListID**, you can do this by openning the web tools in your browser, click on the navigation tab and watch for the navigation log when editing the name of your list, the ID will be visible under the **Preview Tab**
* 5. Use the Trello **ListID** in the loggr.json file under the configuration you want trello to work with.

# 2. Install gem and dependencies
```ruby

#Gemfile
gem "emissary-ruby"
gem "discordrb"
gem "ruby-trello"

#Or install each gem
gem install "discordrb"
gem install "ruby-trello"
gem install "emissary-ruby"

```

# 3. Confugure and Customize
Configure your log readers and commands by creating a file emissary.json inside your project.

See some examples

```json
{
  "server_name": "AppName",
  "header_format": "__***{title}***__",
  "webhooks_url" : "{webhook url}",
  "bot_token" : "{bot token}",
  "trello_public_key": "{trello public key}",
  "trello_member_token": "trello member token",
  "rails": {
    "name": "Rails Logger",
    "path": "path/to/rails/log",
    "condition": "Completed 500 Internal Server Error",
    "lines": 10,
    "fetch_each": 10,
    "language": "ruby",
    "ignore": ["", " ", "  "],
    "command": "rails",
    "bash_command": "",
    "clear_each": 48,
    "report_each": 12,
    "trello_list_id": "",
    "color": "#FF0000",
    "alias": "ror",
    "format": ""
  },
  "disk": {
    "name": "Disk Usage",
    "path": "",
    "condition": "",
    "lines": 0,
    "fetch_each": 0,
    "language": "text",
    "ignore": ["", " ", "  "],
    "command": "disk",
    "bash_command": "df -h",
    "clear_each": 0,
    "report_each": 0,
    "trello_list_id": "",
    "color": "#00FF00",
    "alias": "",
    "format": {"from": "  ", "to": "|"}
  },
  "cpu": {
    "name": "CPU Usage",
    "path": "",
    "condition": "",
    "lines": 0,
    "fetch_each": 0,
    "language": "text",
    "ignore": ["", " ", "  "],
    "command": "cpu",
    "bash_command": "mpstat",
    "clear_each": 0,
    "report_each": 0,
    "trello_list_id": "",
    "color": "#00FF00",
    "alias": "",
    "format": {"from": "  ", "to": "|"}
  },
  "clear_log_file": {
    "name": "Clear log file",
    "path": "",
    "condition": "",
    "lines": 0,
    "fetch_each": 0,
    "language": "text",
    "ignore": ["", " ", "  "],
    "command": "cpu",
    "bash_command": "rm path/to/rails/log && touch path/to/rails/log",
    "clear_each": 0,
    "report_each": 0,
    "trello_list_id": "",
    "color": "#00FF00",
    "alias": "",
    "format": {"from": "", "to": ""}
  }
}
```

# 4. Make it run
Run the **bundle exec emissary** command and pass as parameter the path to the **emissary.json** file you just created

```ruby
bundle exec emissary "/path/to/config/file.json"

```

# 5. If everything goes right
You can type the next commands in your Discord Server Channel and the Chatbot will answer.

```ruby
!emy rails fetch #This will read the log file for the setup with command rails

!emy rails report #this will send to the discord general reports of errors catched

!emy disk #This will send back to discord the usage of the server disk partitions

!emy rails {id} trello #Add message report to trello list
```

# Daemonize Emissary
* Change **WorkingDirectory** and the **ExecStart** to your server configurations
* Change **User** and **Group** to the user you user for deployment

Usually you create this file as: **/lib/systemd/system/emissary.service**
```ruby
[Unit]
Description=emissary
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/home/rails/my_project/current
ExecStart=/home/rails/.rbenv/shims/bundle exec emissary /home/rails/my_project/shared/emissary.json

User=rails
Group=rails
UMask=0002

RestartSec=1
Restart=on-failure

StandardOutput=syslog
StandardError=syslog

SyslogIdentifier=emissary

[Install]
WantedBy=multi-user.target

```

In case you use capistrano and you deamonize Emissary: **config/deploy.rb**

```ruby

namespace :emissary do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'emissary' | xargs kill -TSTP")
    end
  end
  task :restart do
    on roles(:app) do
      execute! :sudo, :systemctl, :restart, :emissary
    end
  end
end

after 'deploy:starting', 'emissary:quiet'
after 'deploy:reverted', 'emissary:restart'
after 'deploy:published', 'emissary:restart'
```


# Roadmap
This tools is in the making
* ~~Multi server with the same BOT~~
* ~~bundle exec runner for better daemonization and independence~~
* Send whole messages batch to trello
* Better command params handling
* Convert the message HASH into a Ruby Class
* Change the JSON config file to a init class configuration for better customization
* Title dates formatting
* Gem dependencies
* Regex conditioning
* Slack Integration
* Email reports Integration
* Authy integration for TwoFactor authentication for sensible commands
* API Keys with ENV variables
