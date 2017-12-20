defaultbrowser
==============

Command line script for getting and setting a default browser (HTTP handler) in Mac OS X.

As there seems no other elegant way of doing it you need some Objective-C code.

The code uses Launch Services. More info on 
[Launch Services Reference](https://developer.apple.com/library/mac/documentation/Carbon/Reference/LaunchServicesReference/Reference/reference.html)


Build
-----
1. Build it.

```
cd defaultbrowser
xcodebuild -project defaultbrowser.xcodeproj -alltargets -configuration Release
```

2. Move it into your path (replace ~/bin to whatever you like)

```
cp build/Release/defaultbrowser ~/bin/
```

Usage
-----

Open the XCode project and build it or download the build/defaultbrowser and put it somewhere
in your path. `chmod +x defaultbrowser` is probably also necessary.

You can set the default browser with:

```
defaultbrowser -set chrome
```

Running defaultbrowser without arguments shows the current setting.
