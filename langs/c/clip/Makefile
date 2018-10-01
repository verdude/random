CC = cc
CXXFLAGS= -Wall -g3

LIBS = $(shell pkg-config --libs libevent_openssl)

DAEMON = clip_daemon
DAEMON_SRC = $(DAEMON:%=%.c)
BUILDDIR = build
OBJS = $(DAEMON_SRC:%.c=%.o)
OBJECTS = $(patsubst %,$(BUILDDIR)/%,$(OBJS))
EXE = $(BUILDDIR)/$(DAEMON:%=%.out)

CLIENT = clip
CLIENT_SRC = $(CLIENT:%=%.c)
CLIENT_EXE = $(BUILDDIR)/$(CLIENT:%=%.out)

top=$(shell git rev-parse --show-top-level)

$(DAEMON): build $(EXE)
	
build:
	mkdir -p build

$(EXE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXE) $(LIBS)
 
$(BUILDDIR)/%.o: %.c
	$(CC) $(CXXFLAGS) -c $< -o $@ $(LIBS)

$(CLIENT): build $(CLIENT_EXE)

$(CLIENT_EXE): $(CLIENT_SRC)
	$(CC) $(CXXFLAGS) -o $(CLIENT_EXE) $(CLIENT_SRC)

.PHONY: clean all install $(CLIENT)
all: $(DAEMON) $(CLIENT)

install: all
	cp $(EXE) $$GITDIR/random/thechosenones/$(DAEMON)
	cp $(CLIENT_EXE) $$GITDIR/random/thechosenones/$(CLIENT)

clean:
	rm -rf $(BUILDDIR)
	rm -f $(CLIENT_EXE)
	rm -f $$GITDIR/random/thechosenones/$(CLIENT)
	rm -f $$GITDIR/random/thechosenones/$(DAEMON)

