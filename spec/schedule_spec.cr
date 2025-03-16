require "./spec_helper"

Spectator.describe Skedjewel::Schedule do
  subject(schedule) { Skedjewel::Schedule.new(schedule_string) }

  describe "#matches?" do
    context "when the schedule time zone has a negative UTC offset (America/Chicago)" do
      let(time_zone) { "America/Chicago" }
      let(location) { Time::Location.load(time_zone) }

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

      context "when the schedule string is '%2:07'" do
        let(schedule_string) { "%2:07" }

        context "when the checked time is local time 06:07" do
          let(time) { Time.local(2025, 3, 16, 6, 7, 1, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 22:07" do
          let(time) { Time.local(2025, 3, 16, 22, 7, 2, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 03:07" do
          let(time) { Time.local(2025, 3, 16, 3, 7, 1, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end

        context "when the checked time is local time 22:08" do
          let(time) { Time.local(2025, 3, 16, 22, 8, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is '**:%5'" do
        let(schedule_string) { "**:%5" }

        context "when the checked time is UTC 00:15:29" do
          let(time) { Time.utc(2025, 3, 15, 0, 15, 29) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is UTC 13:25:48" do
          let(time) { Time.utc(2025, 3, 15, 13, 25, 48) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is UTC 13:26:48" do
          let(time) { Time.utc(2025, 3, 15, 13, 26, 48) }

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
