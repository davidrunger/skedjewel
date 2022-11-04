class Skedjewel::Schedule
  @hour : String
  @minute : String
  @integer_hour : Int32 | Nil
  @integer_minute : Int32 | Nil

  def initialize(schedule_string)
    array = schedule_string.to_s.split(":")
    @hour = array.first
    @minute = array.last
  end

  def matches?(time)
    hour_match?(time) && minute_match?(time)
  end

  private def hour_match?(time)
    @hour == "**" || time.hour == integer_hour
  end

  private def minute_match?(time)
    @minute == "**" || time.minute == integer_minute
  end

  private def integer_hour
    @integer_hour ||= @hour.to_i
  end

  private def integer_minute
    @integer_minute ||= @minute.to_i
  end
end
