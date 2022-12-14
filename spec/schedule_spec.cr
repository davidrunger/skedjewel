require "./spec_helper"

Spectator.describe Skedjewel::Schedule do
  subject(schedule) { Skedjewel::Schedule.new(schedule_string) }

  describe "#matches?" do
    context "when the schedule time zone has a negative UTC offset (America/Chicago)" do
      let(time_zone) { "America/Chicago" }

      before_each do
        Skedjewel.config = Skedjewel::Config.new({"time_zone" => time_zone})
      end

      context "when the schedule string is 23:59" do
        let(schedule_string) { "23:59" }

        context "when the checked time is 23:59 in America/Chicago as a UTC time" do
          let(time) do
            utc_offset = (
              Time.local(Time::Location.load(time_zone)).zone.offset /
              (60 * 60)
            ).to_i

            Time.utc(2022, 11, 5, -1 * utc_offset - 1, 59, 0)
          end

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is 23:59:00Z" do
          let(time) { Time.utc(2022, 11, 4, 23, 59, 0) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is 00:05" do
        let(schedule_string) { "00:05" }

        context "when the checked time is 00:05 in America/Chicago as a UTC time" do
          let(time) do
            utc_offset = (
              Time.local(Time::Location.load(time_zone)).zone.offset /
              (60 * 60)
            ).to_i

            Time.utc(2022, 11, 4, -1 * utc_offset, 5, 10)
          end

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is 00:06:00Z" do
          let(time) { Time.utc(2022, 11, 4, 0, 6, 0) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end
    end

    context "when the schedule time zone has a positive UTC offset" do
      let(time_zone) { "Europe/Moscow" }

      before_each do
        Skedjewel.config = Skedjewel::Config.new({"time_zone" => time_zone})
      end

      context "when the schedule string is 01:30" do
        let(schedule_string) { "01:30" }

        context "when the checked time is 01:30 in Europe/Moscow as a UTC time" do
          let(time) do
            utc_offset = (
              Time.local(Time::Location.load(time_zone)).zone.offset /
              (60 * 60)
            ).to_i

            Time.utc(2022, 11, 4, 25 - utc_offset, 30, 0)
          end

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is 01:30:00Z" do
          let(time) { Time.utc(2022, 11, 5, 1, 30, 0) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end
    end
  end
end
