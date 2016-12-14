#!/usr/bin/env ruby

require "optparse"

def rot(msg,min,max)
    # min is the lowest ascii char and max is the highest (A and z normally)
    for x in 1..(26*2)
        new_msg = ""
        msg.each_char.with_index do | c, i |
            if c == " "
                new_msg += c
                next
            end
            nc = (msg[i].ord + x)
            nc = min.ord-1 + (nc - max.ord) if nc > max.ord
            new_msg += nc.chr
        end
        puts "#{x}: #{new_msg}"
    end
end

if __FILE__ == $0
    options = {}
    OptionParser.new do |opts|
        opts.banner = "Usage: rot_cipher.rb -s'message'"
        opts.on("-m","--message message","The message to do a rot cipher on") do |msg|
                options[:msg] = msg
        end
        opts.on("-n","--min min","smallest ascii char in the set") do |min|
                if min.length > 1
                    puts "invalid min char"
                    min = "a"
                end
                options[:min] = min
        end
        opts.on("-x","--max max","largest ascii char in the set") do |max|
                if max.length > 1
                    puts "invalid max char"
                    max = "z"
                end
                options[:max] = max
        end
    end.parse!
    
    if options[:msg].nil?
        print "Message: "
        options[:msg] = gets.chomp
    end

    msg = options[:msg]#.downcase

    min = ((options[:min] == "") or (options[:min].class != "".class)) ? "a" : options[:min]
    max = ((options[:max] == "") or (options[:max].class != "".class)) ? "z" : options[:max]

    rot(msg,min,max)
end


