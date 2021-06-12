require 'thread'
require 'discordrb/webhooks'

class Loggr

  attr_accessor :messages, :path, :condition, :lines, :fetch_each, :language, :ignore, :command, :bash_command, :clear_each, :trello_list_id, :color, :name, :report_each, :timer, :config, :last_id, :alias

  def initialize(config={})
    @config = config
    init_config
    if @bash_command == ""
      start
    end
  end

  def init_config
    @timer = 0
    @messages = {}
    @name = config["name"]
    @path = config["path"]
    @condition = config["condition"]
    @lines = config["lines"]
    @language = config["language"]
    @ignore = config["ignore"]
    @command = config["command"]
    @bash_command = config["bash_command"]
    @fetch_each = config["fetch_each"]
    @clear_each = config["clear_each"]
    @report_each = config["report_each"]
    @trello_list_id = config["trello_list_id"]
    @color = config["color"]
    @alias = config["alias"]
    @last_id = 0
  end

  def start

    one_at_a_time = Mutex.new

    Thread.new do
      loop do
        one_at_a_time.synchronize do
          if @timer % @fetch_each == 0
            fetch
          end
          if @timer % @clear_each == 0
            clear
          end
          if @timer % @report_each == 0
            report
          end
          @timer += 1
          sleep 1*60
        end
      end
    end

  end

  def fetch
    file = File.open(@path)
    file_lines = file.readlines.map(&:chomp)
    @ignore.each{|i| file_lines.delete(i) }

    file_lines.each_with_index do |line, i|
      if line.include? @condition
        if @messages["#{file_lines[i+1]}"].nil?
          @last_id += 1
          @messages["#{file_lines[i+1]}"] = {
            id: "#{@alias}-#{@last_id}",
            trigger: "Completed 500 Internal Server Error",
            lines: file_lines[i..(i+@lines)],
            count: 1,
            reported: false,
            index: i
          }
        else
          @messages["#{file_lines[i+1]}"][:count] += 1
        end
      end
    end
  end

  def message_by_id(id)
    @messages.each do |k, v|
      return v if v[:id] == id
    end
  end

  def last_message
    message_by_id("#{@alias}-#{@last_id}")
  end

  def lines_to_code(message)
    "#{message[:lines].join("\n")}"
  end

  def truncate_lines(lines, length)
    lines.gsub(/^(.{50,}?).*/m,'\1...')
  end

  def report

    client = Discordrb::Webhooks::Client.new(url: Emissary.webhooks_url)
    client.execute do |builder|
      builder.content = "**Report Alert** from **#{@name}** at #{Time.now}"
      builder.add_embed do |embed|
        embed.title = "#{@condition}"
        embed.description = "**Ocurrences: **\n#{@messages.count}"
        embed.color = @color
        embed.timestamp = Time.now
        embed.fields = []
        @messages.each do |k, v|
          unless v[:reported]
            embed.fields.push({
              "name": "**ID: #{v[:id]}**\n\nOcurrences: #{v[:count]}",
              "value": "```#{@language}\n#{v[:lines][0]}\n#{v[:lines][1]}```"
              })
              v[:reported] = true
            end
          end
        end
      end

      create_trello_card

    end

    def message_to_chat(message)
      "**ID: #{message[:id]}**\nOcurrences: #{message[:count]}\n\n```#{@language}\n#{lines_to_code(message)}```"
    end

    def clear
      init_config
    end

    def create_trello_card
    end
  end
