require "./spec_helper"

Spectator.describe Skedjewel::Schedule do
  subject(schedule) { Skedjewel::Schedule.new(schedule_string) }

  describe "#matches?" do
    context "when the schedule timezone has a negative UTC offset" do
      before_each do
        Skedjewel.config = Skedjewel::Config.new({"time_zone" => "America/Chicago"})
      end

      context "when the schedule string is 23:59" do
        let(schedule_string) { "23:59" }

        context "when the checked time is 04:59:00Z" do
          let(time) { Time.utc(2022, 11, 5, 4, 59, 0) }

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

        context "when the checked time is 05:05:10Z" do
          let(time) { Time.utc(2022, 11, 4, 5, 5, 10) }

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

    context "when the schedule timezone has a positive UTC offset" do
      before_each do
        Skedjewel.config = Skedjewel::Config.new({"time_zone" => "Europe/Moscow"})
      end

      context "when the schedule string is 01:30" do
        let(schedule_string) { "01:30" }

        context "when the checked time is 22:30:00Z" do
          let(time) { Time.utc(2022, 11, 4, 22, 30, 0) }

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
