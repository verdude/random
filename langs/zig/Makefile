rtmp:
	zig build-exe -OReleaseSmall rtmp.zig

.PHONY: install clean
install: rtmp
	install rtmp ../../thechosenones/

clean:
	rm -f rtmp
	rm -f rtmp.o
	rm -f ../../thechosenones/rtmp
