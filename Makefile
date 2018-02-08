BIN ?= defaultbrowser
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

CC = gcc
CFLAGS = -O2

.PHONY: all install uninstall clean

all:
	gcc -o $(BIN) $(CFLAGS) -framework Foundation -framework ApplicationServices src/main.m

install: all
	install -d $(BINDIR)
	install -m 755 $(BIN) $(BINDIR)

uninstall:
	rm -f $(BINDIR)/$(BIN)

clean:
	rm -f $(BIN)