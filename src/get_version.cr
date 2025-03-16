require "yaml"

puts(YAML.parse(File.read("shard.yml"))["version"].as_s)
