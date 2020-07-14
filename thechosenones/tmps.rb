#!/usr/bin/env ruby
dirs = Dir["#{File.expand_path('~')}/tmpdir-*"]

puts "Select one plox:"
puts (dirs.map.with_index do |s, i|
  "#{i}. #{s}"
end.join("\n"))

n = gets.chomp.to_i

if n < dirs.count
  puts dirs[n]
else
  puts "badbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbad"
end
