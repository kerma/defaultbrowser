defaultbrowser
==============

Command line tool for setting the default browser (HTTP handler) in macOS X.

Install
-------

Build it:

```
make
```

Install it into your executable path:

```
make install
```

Usage
-----

Set the default browser with, e.g.:

```
defaultbrowser chrome
```

Running `defaultbrowser` without arguments lists available HTTP handlers and shows the current setting.

How does it work?
-----------------

The code uses the [macOS Launch Services API](https://developer.apple.com/documentation/coreservices/launch_services).

Additional Resources
--------------------

- [Bash completion](https://github.com/jonasbn/bash_completion_defaultbrowser) for `defaultbrowser`

License
-------

MIT
