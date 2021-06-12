# Emissary
Simple error catcher integrated with services like Discord and Trello, use chatbots to monitor your application and server.
Receive error catching reports to a Discord Server Channel, and use chatbots to send commands and fetch reports.

# Features
* This tools allows you to configurate the errors or lines you want to capture from any log file, in this example you will find a configuration for catching HTTP ERROR 500.
* You can configurate the timeframes in which the logs will be read, the conditions that triggers the errores, the lines to fetch from the files, the language to markup the error to discord, characters to ignore, how often the errors fetched would be clear, and how often you want a receive reports with error ocurrences.
* You can also use chatbots to fetch and generate reports any time outside the timeframes configurated.
* You can also configurate linux commands and receive in discord the outputs or results.


# Roadmap
This tools is in the making
* Upload as Ruby Gem
* Implement Gem [jeremytregunna/ruby-trello](https://github.com/jeremytregunna/ruby-trello) For managinf Trello Cards with error catching.
*

# Setup your Discord Server, Channel, Application and Bot
* 1. Go To [Discord Developers](https://discord.com/developers)
* 2. Create a new application and under the Bot option create a new bot
* 3. Add your new bot to your server Channel
* 4. Create a webhook in you server channel
* 5. Paste the webhooks url and chat bot token in the Emissary configuration file.

# 2. Download / Clone the code
```ruby

git clone git@github.com:MakarovCode/Emissary.git

```

# 3. Create a file runner.rb with the next lines:
```ruby

require './emissary'

Emissary.configure do |config|
  config.webhooks_url  = '{webhooks_url}'
  config.bot_token  = '{bot_token}'
end

emi = Emissary.new

```

# 4. Configure your log readers and commands in the loggr.json file

See some examples

```javascript
{
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
    "alias": "ror"
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
    "alias": ""
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
    "alias": ""
  }
}
```

# 5. If everything goes write
You can type the next commands in your Discord Server Channel and the Chatbot will answer.

```ruby
!emy rails fetch #This will read the log file for the setup with command rails

!emy rails report #this will send to the discord general reports of errors catched

!emy disk #This will send back to discord the usage of the server disk partitions
```
