CC = gcc
CXXFLAGS=-w -Wall

LIBS =

SRC = $(wildcard *.c)
BUILDDIR = build
OBJS = $(SRC:%.c=%.o)
OBJECTS = $(patsubst %,$(BUILDDIR)/%,$(OBJS))
EXE = $(BUILDDIR)/wut.out

.PHONY: clean folder
all: folder $(EXE)
	
folder:
	mkdir -p build

$(EXE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXE)
 
$(BUILDDIR)/%.o: %.c
	$(CC) -c $(CXXFLAGS) $< -o $@ $(LIBS)

clean:
	rm -rf $(BUILDDIR)

