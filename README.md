defaultbrowser
==============

Command line tool for setting the default browser (HTTP handler) in macOS X.

Install
-------

Build it:

```
xcodebuild -project defaultbrowser.xcodeproj -alltargets -configuration Release
```

Move it into your executable path:

```
cp build/Release/defaultbrowser /usr/local/bin/
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
