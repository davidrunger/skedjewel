require "option_parser"
require "../src/version"
require "../src/skedjewel"

STDOUT.flush_on_newline = true

OptionParser.parse do |parser|
  parser.on "-v", "--version", "Show version" do
    puts("Skedjewel #{Skedjewel::VERSION} (compiled with Crystal #{Crystal::VERSION})")
    exit
  end
end

Skedjewel::Runner.new.run
