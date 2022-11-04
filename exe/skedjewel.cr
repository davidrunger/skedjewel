require "option_parser"
require "../src/version"
require "../src/skedjewel"

OptionParser.parse do |parser|
  parser.on "-v", "--version", "Show version" do
    puts(Skedjewel::VERSION)
    exit
  end
end

Skedjewel::Runner.new.run
