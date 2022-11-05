require "./spec_helper"

describe Skedjewel::Schedule do
  describe "#matches?" do
    context "when the schedule string is 23:59" do
      context "when the checked time is 23:59:00" do
        it "returns true" do
          schedule = Skedjewel::Schedule.new("23:59")
          time = Time.local(2022, 11, 4, 23, 59, 0)
          schedule.matches?(time).should be_true
        end
      end

      context "when the checked time is 23:58:59" do
        it "returns false" do
          schedule = Skedjewel::Schedule.new("23:59")
          time = Time.local(2022, 11, 4, 23, 58, 59)
          schedule.matches?(time).should be_false
        end
      end
    end

    context "when the schedule string is 00:05" do
      context "when the checked time is 00:05:10" do
        it "returns true" do
          schedule = Skedjewel::Schedule.new("00:05")
          time = Time.local(2022, 11, 4, 0, 5, 10)
          schedule.matches?(time).should be_true
        end
      end

      context "when the checked time is 00:06:00" do
        it "returns false" do
          schedule = Skedjewel::Schedule.new("00:05")
          time = Time.local(2022, 11, 4, 0, 6, 0)
          schedule.matches?(time).should be_false
        end
      end
    end
  end
end
