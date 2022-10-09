class Skedjewel::Config
  @config_hash : YAML::Any

  def initialize(config_hash)
    @config_hash = config_hash
  end

  def redis_url
    ENV.fetch("REDIS_URL", "redis://localhost:6379")
  end

  def app_redis_db
    @config_hash["app_redis_db"] || 0
  end

  def sidekiq_redis_db
    @config_hash["sidekiq_redis_db"] || 0
  end
end
