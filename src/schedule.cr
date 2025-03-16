class Skedjewel::Schedule
  MODULUS_REGEX = /^%(?<modulus>\d{1,2})$/

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
    if @schedule_hour == "**"
      true
    elsif @schedule_hour.matches?(MODULUS_REGEX)
      hour_modulo_match?(time)
    else
      time.to_utc.hour == utc_scheduled_integer_hour
    end
  end

  private def hour_modulo_match?(time)
    modulo_match?(@schedule_hour, time.hour)
  end

  private def minute_match?(time)
    if @minute == "**"
      true
    elsif @schedule_hour == "**" && @minute.matches?(MODULUS_REGEX)
      minute_modulo_match?(time)
    else
      time.minute == integer_minute
    end
  end

  private def minute_modulo_match?(time)
    modulo_match?(@minute, time.minute)
  end

  private def modulo_match?(schedule_for_time_unit, actual_time_unit)
    modulus = schedule_for_time_unit.match!(MODULUS_REGEX)["modulus"].to_i
    (actual_time_unit % modulus) == 0
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
