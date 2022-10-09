require "./schedule"
require "json"
require "random/secure"

class Skedjewel::Task
  def initialize(job_name : String, schedule_string, runner : Skedjewel::Runner)
    @job_name = job_name
    @schedule = Skedjewel::Schedule.new(schedule_string)
    @runner = runner
  end

  def run
    @runner.lock_manager.lock(resource_key(Time.local), 60_000)
    Skedjewel.sidekiq_redis.lpush("queue:default", job_hash.to_json)

    nil
  end

  def should_run?
    current_time = Time.local
    @schedule.matches?(current_time) && !already_ran?(current_time)
  end

  private def already_ran?(time)
    @runner.lock_manager.locked?(resource_key(time))
  end

  private def resource_key(time)
    "redis-lock:#{@job_name}:#{time.to_s("%H:%M")}"
  end

  private def job_hash
    # https://github.com/mperham/sidekiq/wiki/FAQ#how-do-i-push-a-job-to-sidekiq-without-ruby
    current_time = Time.local.to_unix_f
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
