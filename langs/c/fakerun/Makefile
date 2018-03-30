CXX= gcc $(FLAGS)

FLAGS=

all: delay

delay:
	$(CXX) -o ./build/runprog runprog.c
	
windows:
	$(CXX) --host=x86_64-w64-mingw32 -o ./build/runprog runprog.c

clean:
	rm -f build/*
