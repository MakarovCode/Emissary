require 'discordrb'

require 'pry';
require "json"


require './lib/loggr';

class Emissary

  class << self
    attr_accessor :webhooks_url, :bot_token, :trello_public_key, :trello_member_token, :server_name, :header_format
    def configure(&block)
      block.call(self)
    end

    def header
      header_format.gsub("{title}", server_name)
    end
  end

  attr_accessor :loggrs

  def configure(&block)
    block.call(self)
  end

  def initialize
    @loggrs = {}
    read_loggrs
    init_bot
  end

  def get_message
  end

  def respond
  end

  def read_loggrs

    file = File.open "./lib/loggr.json"
    raw_loggrs = JSON.load file
    raw_loggrs.each do |k, v|
      loggr = Loggr.new v
      loggrs[loggr.command] = loggr
    end
    file.close
  end

  def init_bot


    bot = Discordrb::Commands::CommandBot.new token: Emissary.bot_token, prefix: '!'

    bot.command :emy do |event, *args|
      puts "===> Receiving request bot"
      if args.count > 0
        command = args[0]
        loggr = loggrs[command]
        unless loggr.nil?
          if loggr.bash_command == ""
            if args.count > 1
              if args[1] == "report"
                loggr.report
                "#{Emissary.header}\nGenerating Last Report"
              elsif args[1] == "fetch"
                loggr.fetch
                "#{Emissary.header}\nFetching Report"
              elsif args[1] == "clear"
                loggr.clear
                "#{Emissary.header}\nClearing Report"
              elsif args[1] == "last"
                loggr.message_to_chat loggr.last_message
              elsif ![nil, ""].include?(args[1]) && args[1].include?(loggr.alias)
                if args.count > 2
                  if args[2] == "trello"
                    card_url = loggr.create_trello_card loggr.message_by_id(args[1])
                    "#{Emissary.header}\n**Trello card added.**\n#{card_url}"
                  end
                else
                  loggr.message_to_chat loggr.message_by_id(args[1])
                end
              else
                "#{Emissary.header}\nWrong arguments for command #{command}:\n**last**: Last Message.\n**report**: Generate report before time.\n**{id}**: Message with ID"
              end
            else
              "#{Emissary.header}\nYou didn't write an argument:\n**last**: Last Message.\n**report**: Generate report before time.\n**{id}**: Message with ID"
            end
          else
            "#{Emissary.header}\n#{loggr.syscall}"
          end
        else
          "#{Emissary.header}\nCommand not found: #{command}"
        end
      else
        "#{Emissary.header}\nYou didn't write a command"
      end
    end

    bot.run
  end



end
