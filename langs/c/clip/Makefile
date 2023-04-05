CC := cc
CXXFLAGS := -Wall -g3

LIBS := $(shell pkg-config --libs libevent_openssl)

DAEMON := clip_daemon
DAEMON_SRC := $(DAEMON:%=%.c)
BUILDDIR := build
OBJS := $(DAEMON_SRC:%.c=%.o)
OBJECTS := $(patsubst %,$(BUILDDIR)/%,$(OBJS))
EXE := $(BUILDDIR)/$(DAEMON:%=%.out)

CLIENT := clip
CLIENT_SRC := $(CLIENT:%=%.c)
CP_SRC := cp.c
CLIENT_OBJS := $(BUILDDIR)/$(CLIENT_SRC:%.c=%.o) $(BUILDDIR)/$(CP_SRC:%.c=%.o)
CLIENT_EXE := $(BUILDDIR)/$(CLIENT:%=%.out)

top := $(shell git rev-parse --show-top-level)

$(EXE): $(BUILDDIR) $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXE) $(LIBS)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: %.c
	$(CC) $(CXXFLAGS) -c $< -o $@ $(LIBS)

$(CLIENT): $(BUILDDIR) $(CLIENT_EXE)

$(CLIENT_EXE): $(CLIENT_OBJS)
	$(CC) $(CXXFLAGS) -o $(CLIENT_EXE) $(CLIENT_OBJS)

.PHONY: clean all install install-clip $(CLIENT)
all: $(EXE) $(CLIENT)

install: all
	cp $(EXE) $$GITDIR/random/thechosenones/$(DAEMON)
	cp $(CLIENT_EXE) $$GITDIR/random/thechosenones/$(CLIENT)

install-$(CLIENT): $(CLIENT)
	cp $(CLIENT_EXE) $$GITDIR/random/thechosenones/$(CLIENT)

clean:
	rm -rf $(BUILDDIR)
	rm -f $(CLIENT_EXE)
	rm -f $$GITDIR/random/thechosenones/$(CLIENT)
	rm -f $$GITDIR/random/thechosenones/$(DAEMON)

