BIN ?= defaultbrowser
PREFIX ?= /usr/local

CC = gcc
CFLAGS = -O2

.PHONY: all install uninstall clean

all:
	gcc -o $(BIN) $(CFLAGS) -framework Foundation -framework ApplicationServices src/main.m

install:
	cp $(BIN) $(PREFIX)/bin/

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)

clean:
	rm -f $(BIN)