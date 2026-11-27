BIN ?= defaultbrowser
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

CC ?= gcc
CFLAGS ?= -O2 -mmacosx-version-min=11.0

.PHONY: all install uninstall clean

all: $(BIN)

$(BIN):
	$(CC) -o $(BIN) $(CFLAGS) -framework Foundation -framework ApplicationServices -framework AppKit src/main.m

install: $(BIN)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(BIN) $(DESTDIR)$(BINDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN)

clean:
	rm -f $(BIN)
