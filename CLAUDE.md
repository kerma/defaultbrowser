# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`defaultbrowser` is a macOS command-line tool (Objective-C) that reads and sets the default HTTP/HTTPS handler using the macOS Launch Services API. The entire implementation lives in `src/main.m`.

## Build commands

```sh
make          # build the binary
make install  # install to /usr/local/bin (override with PREFIX=...)
make clean    # remove the binary
```

The binary is compiled directly with `gcc` (or `clang` via the `CC` variable) against the `Foundation` and `ApplicationServices` frameworks. There is no Xcode project.

## Architecture

All logic is in `src/main.m`:

- `get_http_handlers()` — calls `LSCopyAllHandlersForURLScheme("http")` and returns a dict mapping short name → bundle ID (e.g. `"chrome"` → `"com.google.chrome"`).
- `get_current_http_handler()` — calls `LSCopyDefaultHandlerForURLScheme("http")` and returns the short name.
- `set_default_handler()` — calls `LSSetDefaultHandlerForURLScheme` for both `http` and `https`.
- `main()` — with no args, lists all handlers (marking the current one with `*`); with one arg, sets that browser as default.

Bundle ID → short name conversion strips everything before the last `.` and lowercases it (`app_name_from_bundle_id`). Browser name matching uses `caseInsensitiveCompare`.

## macOS-specific notes

- Requires macOS. Launch Services functions (`LS*`) are in `ApplicationServices.framework`.
- `LSCopyAllHandlersForURLScheme` is deprecated on macOS 12+ but still functional. Future macOS versions may break it.
- Setting the default browser may trigger a system confirmation dialog on newer macOS versions.
