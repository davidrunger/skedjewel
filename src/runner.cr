require "./task"
require "./lock_manager"
require "./version"

class Skedjewel::Runner
  NANOSECONDS_IN_A_SECOND = 1_000_000_000

  getter :tasks

  @@began_exit_process = false

  def initialize
    jobs_by_rails_env = Skedjewel.parsed_config_file["jobs_by_rails_env"].as_h
    jobs_for_env =
      (to_hash(jobs_by_rails_env["all"]?) || {} of String => String).merge(
        to_hash(jobs_by_rails_env[ENV.fetch("RAILS_ENV", "development")]?) || {} of String => String
      )
    @tasks = [] of Skedjewel::Task
    @tasks =
      jobs_for_env.map do |(job_name, schedule_string)|
        Skedjewel::Task.new(
          job_name,
          schedule_string,
          self,
        )
      end
  end

  # Helper method to convert YAML::Any? to Array(Hash(String, String)).
  private def to_hash(yaml_any : YAML::Any?) : Hash(String, String)
    if yaml_any
      yaml_any.as_h.transform_keys(&.to_s).transform_values(&.to_s).as(Hash(String, String)) # Convert to hash with string keys/values
    else
      {} of String => String
    end
  end

  def run
    [Signal::INT, Signal::TERM].each do |signal|
      signal.trap do
        if !@@began_exit_process
          @@began_exit_process = true
          signal_name = signal.to_s.gsub("Signal::", "")
          ::Log.info do
            "Thanks for using Skedjewel! " \
            "Received #{signal_name} signal. " \
            "Exiting now. (PID:#{Process.pid} time:#{Time.local.to_unix_f})"
          end
          exit(0)
        end
      end
    end

    STDOUT.sync = true
    ::Log.info { "Skedjewel #{Skedjewel::VERSION} is running with PID #{Process.pid}." }

    loop do
      execute_tasks

      sleep(
        Time::Span.new(
          nanoseconds: seconds_to_nanoseconds(
            seconds_until_next_minute(Time.local) +
            0.001, # Add a millisecond to ensure we go into the next minute.
          ),
        )
      )
    end
  end

  memoize def lock_manager : Skedjewel::LockManager
    Skedjewel::LockManager.new
  end

  def seconds_until_next_minute(time)
    seconds_into_minute = time.second.to_f + (time.to_unix_f % 1.0)
    60.0 - seconds_into_minute
  end

  private def execute_tasks
    @tasks.each do |task|
      task.run if task.should_run?
    end
  end

  private def seconds_to_nanoseconds(seconds)
    (seconds * NANOSECONDS_IN_A_SECOND).to_i64
  end
end
