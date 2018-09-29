CC = cc
CXXFLAGS=-w -Wall

LIBS = `pkg-config --libs libevent_openssl`

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
	$(CC) $(OBJECTS) -o $(EXE) $(LIBS)
 
$(BUILDDIR)/%.o: %.c
	$(CC) $(CXXFLAGS) -c $< -o $@ $(LIBS)

clean:
	rm -rf $(BUILDDIR)

