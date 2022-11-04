require "../src/version"
require "../src/skedjewel"

if ARGV == ["--version"]
  puts(Skedjewel::VERSION)
else
  Skedjewel::Runner.new.run
end
