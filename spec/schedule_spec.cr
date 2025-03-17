require "./spec_helper"

Spectator.describe Skedjewel::Schedule do
  subject(schedule) { Skedjewel::Schedule.new(schedule_string) }

  describe "#matches?" do
    let(location) { Time::Location.load(time_zone) }

    context "when the schedule time zone has a negative UTC offset (America/Chicago)" do
      let(time_zone) { "America/Chicago" }

      before_each do
        Skedjewel.config = Skedjewel::Config.new({"time_zone" => time_zone})
      end

      context "when the schedule string is 23:59" do
        let(schedule_string) { "23:59" }

        context "when the checked time is local time 23:59" do
          let(time) { Time.local(2025, 3, 16, 23, 59, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 23:58" do
          let(time) { Time.local(2025, 3, 16, 23, 58, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is 00:05" do
        let(schedule_string) { "00:05" }

        context "when the checked time is local time 00:05" do
          let(time) { Time.local(2025, 3, 16, 0, 5, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 00:06" do
          let(time) { Time.local(2025, 3, 16, 0, 6, 0, location: location) }

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

        context "when the checked time is local time 00:15:29" do
          let(time) { Time.local(2025, 3, 16, 0, 15, 29, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 13:25:48" do
          let(time) { Time.local(2025, 3, 15, 13, 25, 48, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 13:26:48" do
          let(time) { Time.local(2025, 3, 15, 13, 26, 48, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is '**:%10+2'" do
        let(schedule_string) { "**:%10+2" }

        context "when the checked time is local time 08:22" do
          let(time) { Time.local(2025, 3, 16, 8, 22, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 08:27" do
          let(time) { Time.local(2025, 3, 16, 8, 27, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is '%2+1:17'" do
        let(schedule_string) { "%2+1:17" }

        context "when the checked time is local time 15:17" do
          let(time) { Time.local(2025, 3, 16, 15, 17, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 16:17" do
          let(time) { Time.local(2025, 3, 16, 16, 17, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is '02:%5'" do
        let(schedule_string) { "02:%5" }

        context "when the checked time is local time 02:30" do
          let(time) { Time.local(2025, 3, 16, 2, 30, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 22:35" do
          let(time) { Time.local(2025, 3, 16, 22, 35, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end

        context "when the checked time is local time 02:31" do
          let(time) { Time.local(2025, 3, 16, 2, 31, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end

        context "when the checked time is local time 03:30" do
          let(time) { Time.local(2025, 3, 16, 3, 30, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end

      context "when the schedule string is '%4:%10'" do
        let(schedule_string) { "%4:%10" }

        context "when the checked time is local time 08:50" do
          let(time) { Time.local(2025, 3, 16, 8, 50, 1, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 00:00" do
          let(time) { Time.local(2025, 3, 16, 0, 0, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 00:05" do
          let(time) { Time.local(2025, 3, 16, 0, 5, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end

        context "when the checked time is local time 02:00" do
          let(time) { Time.local(2025, 3, 16, 2, 0, 0, location: location) }

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

        context "when the checked time is local time 01:30" do
          let(time) { Time.local(2025, 3, 16, 1, 30, 0, location: location) }

          it "returns true" do
            expect(schedule.matches?(time)).to eq(true)
          end
        end

        context "when the checked time is local time 02:30" do
          let(time) { Time.local(2025, 3, 16, 2, 30, 0, location: location) }

          it "returns false" do
            expect(schedule.matches?(time)).to eq(false)
          end
        end
      end
    end
  end
end
