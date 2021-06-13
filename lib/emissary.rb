require 'discordrb'

require 'pry';
require "json"
require 'open3'

require './lib/loggr';

class Emissary

  class << self
    attr_accessor :webhooks_url, :bot_token, :trello_public_key, :trello_member_token
    def configure(&block)
      block.call(self)
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
                "Generating Last Report"
              elsif args[1] == "fetch"
                loggr.fetch
                "Fetching Report"
              elsif args[1] == "clear"
                loggr.clear
                "Clearing Report"
              elsif args[1] == "last"
                loggr.message_to_chat loggr.last_message
              elsif ![nil, ""].include?(args[1]) && args[1].include?(loggr.alias)
                if args.count > 2
                  if args[2] == "trello"
                    card_url = loggr.create_trello_card loggr.message_by_id(args[1])
                    "**Trello card added.**\n#{card_url}"
                  end
                else
                  loggr.message_to_chat loggr.message_by_id(args[1])
                end
              else
                "Wrong arguments for command #{command}:\n**last**: Last Message.\n**report**: Generate report before time.\n**{id}**: Message with ID"
              end
            else
              "You didn't write an argument:\n**last**: Last Message.\n**report**: Generate report before time.\n**{id}**: Message with ID"
            end
          else
            syscall(loggr.bash_command)
          end
        else
          "Command not found: #{command}"
        end
      else
        "You didn't write a command"
      end
    end

    bot.run
  end

  def syscall(*cmd)
    begin
      stdout, stderr, status = Open3.capture3(*cmd)
      status.success? && stdout.slice!(0..-(1 + $/.size)).gsub(/^(.{1500,}?).*/m,'\1...') # strip trailing eol
    rescue
      "The command #{cmd} could not be executed"
    end
  end

end
