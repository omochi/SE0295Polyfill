# SE0295Polyfill

You can generate Swift source code of enum with associated values which complies with SE-0295.

# Command Line Tool

```
$ swift run se0295 <file>
```

## Example

```
$ swift run se0295 Example
generate: Command-SE0295.gen.swift
```

# API

`App`: Command Line Tool implementation.

`CodeGenerator`: Generator.

# Testing

## Xcode

Set environment variable.

```
DYLD_LIBRARY_PATH = /Applications/Xcode12.5.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx
OS_ACTIVITY_DT_MODE = NO
```

`OS_ACTIVIYT_DT_MODE` suppress following message.

```
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc for reading: Too many levels of symbolic links
```

