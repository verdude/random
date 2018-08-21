CC = gcc
CCFLAGS = -Wall -O3 -fpic -g3
LIBS =

EXEC = borked.out
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

all: $(OBJECTS) $(SOURCES)
	$(CC) -o $(EXEC) $(OBJECTS) $(LIBS)

%.o: %.c
	$(CC) $(CCFLAGS) -c $< -o $@

.PHONY: clean
clean: 
	rm -f *.o $(EXEC)
