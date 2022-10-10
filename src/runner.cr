require "./task"
require "./lock_manager"

class Skedjewel::Runner
  getter :tasks

  def initialize
    @tasks = [] of Skedjewel::Task
    @tasks =
      Skedjewel.parsed_config_file["jobs"].as_h.map do |job_name, schedule_string|
        Skedjewel::Task.new(
          job_name.as_s,
          schedule_string.as_s,
          self,
        )
      end
  end

  def run
    Signal::INT.trap do
      ::Log.info { "Thanks for using Skedjewel! Exiting now." }
      exit(0)
    end

    STDOUT.sync = true
    ::Log.info { "Skedjewel is running with PID #{Process.pid}." }

    loop do
      execute_tasks
      sleep(seconds_until_next_minute(Time.local) + 0.001)
    end
  end

  def lock_manager
    @lock_manager ||= Skedjewel::LockManager.new
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
end
