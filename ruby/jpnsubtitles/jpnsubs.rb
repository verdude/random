#!/usr/bin/env ruby

require "pry"
require "optparse"


class Line
	def initialize(lines,section)
		@lines = lines.map{|x| x.chomp("\n") if x[-1] == "\n"}
		@section = section
	end

	def insertPunc(idx,punc)
		for i in 0...@lines.length
			if idx <= @lines[i].length
				# insert
				@lines[i].insert(idx,punc)
				break
			else
				idx-=@lines[i].length
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

def do_it_to_it(_txtFile,_captionFile,_outFile)
	enum = IO.foreach("caps.srt",:encode=>"utf-8")
	outFile = File.open(_outFile, "w")
	section = 1
	capLine = enum.next
	IO.foreach("trans.txt",:encode=>"utf-8") do |line|
		next if line == "\n"
		while isNum(capLine) or isTimeCode(capLine) or capLine == "\n"
			outFile.puts(capLine)
			capLine = enum.next
		end
		caps = []
		until isNum(capLine) or isTimeCode(capLine) or capLine == "\n"
			caps.push(capLine)
			capLine = enum.next
		end
		caption = Line.new(caps,section)
		insertPuncs(line,caption)
		lines = caption.getLines()
		outFile.puts(lines)
		section+=1
	end
end

if __FILE__ == $0
	options = {}
	OptionParser.new do |opts|
		opts.banner = "Usage: jpnsubs.rb [options]"
		opts.on("-s","--srt-file","The srt file that needs punctuation") do |srt|
			options[:srt] = srt
		end
		opts.on("-t","--txt-file","The txt file that contains all of the lines with punctuation") do |txt|
			options[:txt] = txt
		end
		opts.on("-o","--out-file","The name to give the new srt file") do |out|
			options[:out] = out
		end
		opts.on("-h","--help","Prints the required arguments.") do
			puts opts
			abort
		end
	end.parse!
	
	if options[:srt].nil? or options[:txt].nil? or options[:out].nil?
		puts "-t,-s,-o options are required.\nRun with -h for help."
		abort
	end

	#formatTranscription()
	do_it_to_it(options[txt],options[srt],options[out])
end

