require "./spec_helper"

Spectator.describe Skedjewel::Schedule do
  subject(schedule) { Skedjewel::Schedule.new(schedule_string) }

  describe "#matches?" do
    context "when the schedule string is 23:59" do
      let(schedule_string) { "23:59" }

      context "when the checked time is 23:59:00" do
        let(time) { Time.local(2022, 11, 4, 23, 59, 0) }

        it "returns true" do
          expect(schedule.matches?(time)).to eq(true)
        end
      end

      context "when the checked time is 23:58:59" do
        let(time) { Time.local(2022, 11, 4, 23, 58, 59) }

        it "returns false" do
          expect(schedule.matches?(time)).to eq(false)
        end
      end
    end

    context "when the schedule string is 00:05" do
      let(schedule_string) { "00:05" }

      context "when the checked time is 00:05:10" do
        let(time) { Time.local(2022, 11, 4, 0, 5, 10) }

        it "returns true" do
          expect(schedule.matches?(time)).to eq(true)
        end
      end

      context "when the checked time is 00:06:00" do
        let(time) { Time.local(2022, 11, 4, 0, 6, 0) }

        it "returns false" do
          expect(schedule.matches?(time)).to eq(false)
        end
      end
    end
  end
end
