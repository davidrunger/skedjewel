require "./schedule"
require "json"
require "random/secure"

class Skedjewel::Task
  def initialize(job_name : String, schedule_string, runner : Skedjewel::Runner)
    @job_name = job_name
    @schedule = Skedjewel::Schedule.new(schedule_string)
    @schedule_time_location = Time::Location.load(Skedjewel.config.time_zone)
    @runner = runner
  end

  def run
    time = Time.local
    lock_duration = @runner.seconds_until_next_minute(time).ceil.to_i
    @runner.lock_manager.with_lock(resource_key(time), lock_duration) do
      Skedjewel.sidekiq_redis.lpush("queue:default", job_hash.to_json)
    end

    nil
  end

  def should_run?
    @schedule.matches?(Time.local(@schedule_time_location))
  end

  private def resource_key(time)
    "redis-lock:#{@job_name}:#{time.to_s("%H:%M")}"
  end

  private def job_hash
    # https://github.com/mperham/sidekiq/wiki/FAQ#how-do-i-push-a-job-to-sidekiq-without-ruby
    current_time = (Time.local.to_unix_f * 1_000).round
    {
      "class"       => @job_name,
      "queue"       => "default",
      "args"        => [] of JSON::Any,
      "retry"       => true,
      "jid"         => Random::Secure.hex(12),
      "created_at"  => current_time,
      "enqueued_at" => current_time,
    }
  end
end
