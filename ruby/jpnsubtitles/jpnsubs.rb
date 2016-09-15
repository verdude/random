#!/usr/bin/env ruby

require "pry"

class Line
	def initialize(lines)
		@lines = lines.map{|x| x.chomp("\n") if x[-1] == "\n"}
		@strLen = @lines.join.length
	end

	def insertPunc(idx,punc)
		for i in 0...@lines.length
			if idx <= @lines[i].length
				# insert
				@lines[i].insert(idx,punc)
				break
			else
				idx-=@lines.length
			end
		end
	end

	def getLines()
		@lines.map {|x| x.concat("\n") }.join
	end
end

def isNum(str)
	begin
		Float(str)
		return true
	rescue ArgumentError
		return false
	end
end

def isTimeCode(str)
	a = str.split(":")
	if a.length == 5
		arrow = a[2]
		return arrow.index("-->") ? true : false
	else
		return false
	end
end

def insertPuncs(txt,srt)
	puncs = ["「","」","?","、","。","？"]
	for i in 0...txt.length
		puncIndex = puncs.index(txt[i])
		if puncIndex
			# insert punc
			srt.insertPunc(i,puncs[puncIndex])
		end
	end
end

def do_it_to_it()
	enum = IO.foreach("caps.srt",:encode=>"utf-8")
	IO.foreach("trans.txt",:encode=>"utf-8") do |line|
		capLine = enum.next
		while isNum(capLine) or isTimeCode(capLine) or capLine == "\n"
			
			capLine = enum.next
		end
		caps = [capLine]
		capLine = enum.next
		until isNum(capLine) or isTimeCode(capLine) or capLine == "\n"
			caps.push(capLine)
			capLine = enum.next
		end
		caption = Line.new(caps)
		insertPuncs(line,caption)
		lines = caption.getLines()
		print lines.concat("\n")
	end 
end

if __FILE__ == $0
	do_it_to_it()
end

