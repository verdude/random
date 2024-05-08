dryclean := n
release := -OReleaseSmall

ifneq ($(dryclean),n)
override dryclean :=
endif

rtmp: rtmp.zig
	zig build-exe $(release) rtmp.zig

rotation: rotation.zig
	zig build-exe $(release) rotation.zig

.PHONY: install clean
install: rtmp
	install rtmp ../../thechosenones/

clean:
	git clean -xf$(dryclean)
