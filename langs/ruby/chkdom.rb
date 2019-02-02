#!/usr/bin/env ruby

print "Length: "
length = gets.chomp.to_i

if length < 0
	length = 0
end
if length > 5
	length = 3
end

start = Time.now
list = (('a'*length)..('z'*length)).to_a
finish = Time.now

puts "list gen in: #{finish-start}"
puts "list len: #{list.length}"

require 'unirest'

list.each do |dom|
	print dom
	#Unirest.get
end

