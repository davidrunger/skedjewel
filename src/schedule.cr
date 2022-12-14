class Skedjewel::Schedule
  @schedule_hour : String
  @minute : String
  @utc_scheduled_integer_hour : Int32 | Nil
  @integer_minute : Int32 | Nil

  def initialize(schedule_string)
    @schedule_hour, @minute = schedule_string.to_s.split(":")
  end

  def matches?(time)
    hour_match?(time) && minute_match?(time)
  end

  private def hour_match?(time)
    @schedule_hour == "**" || time.to_utc.hour == utc_scheduled_integer_hour
  end

  private def minute_match?(time)
    @minute == "**" || time.minute == integer_minute
  end

  private def utc_scheduled_integer_hour
    @utc_scheduled_integer_hour ||= (@schedule_hour.to_i - schedule_time_zone_offset_hours) % 24
  end

  private def schedule_time_zone_offset_hours
    (Time.local(Time::Location.load(Skedjewel.config.time_zone)).zone.offset / (60 * 60)).to_i
  end

  private def integer_minute
    @integer_minute ||= @minute.to_i
  end
end
