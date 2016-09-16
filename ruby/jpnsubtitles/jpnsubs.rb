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
	puncs = ["—","「","」","?","、","。","？"]
	for i in 0...txt.length
		puncIndex = puncs.index(txt[i])
		if puncIndex
			# insert punc
			srt.insertPunc(i,puncs[puncIndex])
		end
	end
end

def do_it_to_it(_txtFile,_captionFile,_outFile)
	puncs = ["—","「","」","?","、","。","？"]
	enum = IO.foreach(_captionFile,:encode=>"utf-8")
	outFile = File.open(_outFile, "w")
	section = 1
	capLine = enum.next
	IO.foreach(_txtFile,:encode=>"utf-8") do |line|
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
		
		# compensate for youtube's random line cutting
		joinedCaption = caps.join
		joinedCaption.gsub!(/[\n「—?、。？」]/,'')
		tline = line.clone
		tline.gsub!(/[\n「—?、。？」]/,'')

		# Youtube downcases the english for some reason
		if joinedCaption != tline and joinedCaption.upcase != tline
			# means that the line from the txt file was cut off and put split into another section when youtube created the srt file
			# 
			# we use an offset because we need to keep the punctuation from the string 'line' on the next iteration
			# offset is the number of punctuation marks that are in the original string that is the truncated down to the size of the 
			# current section of the youtube generated captions (srt file) (which have no punctuation).
			# We leave the rest of the line for the next iteration and proceed with the line we have
			offset = puncs.map{|p|line[0...joinedCaption.length].count(p)}.reduce{|total,n|total+n}
			# special case for punctuation that would be inside the offset
			offsetStrOffset = 0
			totalOffsetStrOffset = 0
			begin
				# check the offset for punctuation and keep incrementing it until we have the original offset amount of
				# non-punctuation characters
				offsetStr = line[joinedCaption.length...joinedCaption.length+offset]
				offsetStrOffset = puncs.map{|p|offsetStr.count(p)}.reduce{|total,n|total+n}
				offsetStrOffset -= totalOffsetStrOffset
				offset += offsetStrOffset
				totalOffsetStrOffset += offsetStrOffset
			end while offsetStrOffset > 0
			# then check if the next_line is made up of only punctuation or nil
			next_line = line[(joinedCaption.length+offset)..-1]
			line = line[0...(joinedCaption.length+offset)]
			to_redo = true
		else
			to_redo = false
		end

		caption = Line.new(caps,section)
		insertPuncs(line,caption)
		lines = caption.getLines()
		outFile.puts(lines)
		section+=1

		if to_redo
			line = next_line
			redo
		end
	end
end

if __FILE__ == $0
	options = {}
	OptionParser.new do |opts|
		opts.banner = "Usage: jpnsubs.rb [options]"
		opts.on("-s","--srt-file file","The srt file that needs punctuation") do |srt|
			options[:srt] = srt
		end
		opts.on("-t","--txt-file file","The txt file that contains all of the lines with punctuation") do |txt|
			options[:txt] = txt
		end
		opts.on("-o","--out-file file","The name to give the new srt file") do |out|
			options[:out] = out
		end
		opts.on("-h","--help","Prints the required arguments. File will be overwritten if it already exists") do
			puts opts
			abort
		end
	end.parse!
	
	if options[:srt].nil? or options[:txt].nil? or options[:out].nil?
		puts "-t,-s,-o options are required.\nRun with -h for help."
		abort
	end

	do_it_to_it(options[:txt],options[:srt],options[:out])
end

