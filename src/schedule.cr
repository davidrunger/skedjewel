class Skedjewel::Schedule
  MODULUS_REGEX = /^%(?<modulus>\d{1,2})$/

  @schedule_hour : String
  @schedule_minute : String

  def initialize(schedule_string)
    @schedule_hour, @schedule_minute = schedule_string.to_s.split(":")
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
      time.hour == scheduled_integer_hour
    end
  end

  private def hour_modulo_match?(time)
    modulo_match?(@schedule_hour, time.hour)
  end

  private def minute_match?(time)
    if @schedule_minute == "**"
      true
    elsif @schedule_minute.matches?(MODULUS_REGEX)
      minute_modulo_match?(time)
    else
      time.minute == scheduled_integer_minute
    end
  end

  private def minute_modulo_match?(time)
    modulo_match?(@schedule_minute, time.minute)
  end

  private def modulo_match?(schedule_for_time_unit, actual_time_unit)
    modulus = schedule_for_time_unit.match!(MODULUS_REGEX)["modulus"].to_i
    (actual_time_unit % modulus) == 0
  end

  private memoize def scheduled_integer_hour : Int32
    @schedule_hour.to_i
  end

  private def schedule_time_zone_offset_hours
    (Time.local(Time::Location.load(Skedjewel.config.time_zone)).zone.offset / (60 * 60)).to_i
  end

  private memoize def scheduled_integer_minute : Int32
    @schedule_minute.to_i
  end
end
