class Skedjewel; end

require "./config"
require "./runner"
require "log"
require "log/io_backend"
require "redis"
require "yaml"

class Skedjewel
  @@config : Skedjewel::Config | Nil

  formatter =
    ::Log::Formatter.new do |entry, io|
      io << entry.message
    end
  ::Log.setup(:info, ::Log::IOBackend.new(formatter: formatter))

  def self.app_redis
    if redis = @@app_redis
      redis
    else
      @@app_redis = Redis.new(url: "#{config.redis_url}/#{config.app_redis_db}")
    end
  end

  def self.sidekiq_redis
    if redis = @@sidekiq_redis
      redis
    else
      @@sidekiq_redis = Redis.new(url: "#{config.redis_url}/#{config.sidekiq_redis_db}")
    end
  end

  def self.config
    if config = @@config
      config
    else
      self.config = Skedjewel::Config.new(parsed_config_file["config"].as_h)
    end
  end

  def self.config=(config)
    @@config = config
  end

  def self.parsed_config_file
    if (parsed_config_file = @@parsed_config_file)
      parsed_config_file
    else
      @@parsed_config_file = YAML.parse(File.read("config/skedjewel.yml"))
    end
  end
end
