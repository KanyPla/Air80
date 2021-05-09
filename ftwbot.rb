DIR = File.expand_path(File.dirname(__FILE__))
Dir.chdir(DIR)
require 'active_record'
require 'sqlite3'
require 'discordrb'
require 'date'
require 'log4r'
require 'require_all'


require_all 'own_lib'
require_all 'models'

Log4r::Logger.root.level = Log4r::DEBUG
$logger = Log4r::Logger.new('discord_bot')
Log4r::StderrOutputter.new 'console'
$logger.add('console')
file = Log4r::FileOutputter.new( 'discord_bot', filename:'prod.log' )
file.formatter = Log4r::PatternFormatter.new(pattern: "%l %d %m")
$logger.add file 
$logger.info 'Starting the bot'
$logger.info 'Initialized logging'

configuration = YAML::load(IO.read('db/config.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
ActiveRecord::Base.time_zone_aware_types = [:datetime, :time]

$logger.info 'Initialized active record'

$logger.info 'Setting the currect time zone'
Time.zone = 'Berlin'

$logger.info 'Initialized models'

TOKEN_FILE = 'token.txt'.freeze
token = Helper.get_token(TOKEN_FILE)

$logger.info 'Loaded token'

REGEX_ADD_FLIGHT_TODAY = /(.+): ([a-zA-Z\-]+) ([0-9]{2}:[0-9]{2})-([0-9]{2}:[0-9]{2})/m
REGEX_ADD_FLIGHT_FUTURE = /(.+): ([a-zA-Z\-]+) ([0-9]{2}.[0-9]{2}.[0-9]{4}) ([0-9]{2}:[0-9]{2})-([0-9]{2}:[0-9]{2})/m

DATE_PARSER = '%Y-%m-%d'.freeze

DATETIME_OUTPUT = '%H:%M %d.%m.%y'.freeze
TIME_OUTPUT = '%H:%M'.freeze

bot = Discordrb::Commands::CommandBot.new token: token, prefix: '!'

$logger.info 'Created bot'

bot.command :help do
  StringBuilder.help
end

bot.command :hello do |event|
  StringBuilder.hello(event.user.name)
end

bot.command :echo do |event, *args|
  StringBuilder.echo("#{args.join(' ')}")
end

bot.command :add do |event, *args|
  Helper.add_today(event, args)
  Helper.show_plan
end

bot.command :future do |event, *args|
  Helper.add_future(event, args)
  Helper.show_plan
end

bot.command :plan do
  Helper.show_plan
end

bot.command :delete do |event, *args|
  Helper.delete(event, args)
  Helper.show_plan
end

bot.command :id do |event, *args|
  Helper.id(event.user.name)
end

bot.command :guinness do |event, *args|
  StringBuilder.guinness(args.join(' '))
end

bot.command :duftbaum do |event, *args|
  StringBuilder.duftbaum(args.join(' '))
end

bot.command :plane_stats do |event, *args|
  Helper.plane_stats(args)
end

bot.command :legs_stats do |event, *args|
  Helper.legs_stats(args)
end

bot.command :pilot_stats do |event, *args|
  Helper.pilot_stats(args)
end

bot.command :change do |event, *args|
  Helper.change_flight(args)
end

bot.run
