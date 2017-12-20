defaultbrowser
==============

Command line tool for setting the default browser (HTTP handler) in macOS X.

Install
-------

Build it:

```
gcc -o defaultbrowser -O2 -framework Foundation -framework ApplicationServices src/main.m
```

Move it into your executable path:

```
cp defaultbrowser /usr/local/bin/
```

Usage
-----

Set the default browser with:

```
defaultbrowser -set chrome
```

Running `defaultbrowser` without arguments shows the current setting.

How does it work?
-----------------

The code uses the [macOS Launch Services API](https://developer.apple.com/documentation/coreservices/launch_services).

License
-------

MIT
