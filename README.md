# Arrow Generator Plugin

[![CI](https://github.com/AhmedOsman00/arrow-generator-plugin/actions/workflows/ci.yml/badge.svg)](https://github.com/AhmedOsman00/arrow-generator-plugin/actions/workflows/ci.yml)
[![Swift Version](https://img.shields.io/badge/Swift-5.9%20|%206.0%20|%206.1%20|%206.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2010.15+-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Swift Package Manager plugin that integrates the Arrow dependency injection code generator with your Swift packages.

## Overview

This plugin automatically generates dependency injection container code for Swift packages using the Arrow code generator. It seamlessly integrates with Swift Package Manager to produce a `dependencies.generated.swift` file for your package.

## Prerequisites

Before using this plugin, you must have the `arrow` binary installed on your system. The plugin requires this external tool to perform code generation.

For installation instructions, please refer to the [Arrow Generator README](https://github.com/AhmedOsman00/arrow-generator#installation).

## Installation

Add the plugin as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AhmedOsman00/arrow-generator-plugin.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

Run the plugin from your package directory:

```bash
swift package plugin arrow-generator
```

The plugin will prompt for permission to write to the package directory and then generate dependency injection code for your package.

> **Note**: Swift Package Manager will automatically prompt for write permission due to the plugin's declared permissions. You can approve this when prompted.

### Specifying a Custom Arrow Binary Path

If the `arrow` binary is not in your system PATH, you can specify its location:

#### Using Command-Line Argument

```bash
swift package plugin arrow-generator --arrow-path /path/to/arrow
```

#### Using Environment Variable

```bash
ARROW_PATH=/path/to/arrow swift package plugin arrow-generator
```

### Specifying a Custom Sources Path

You can override the default sources path if needed:

```bash
swift package plugin arrow-generator --package-sources-path /custom/path/to/sources
```

### Binary Discovery Priority

The plugin searches for the `arrow` binary in the following order:

1. **Command-line argument**: `--arrow-path /path/to/arrow`
2. **Environment variable**: `ARROW_PATH`
3. **System PATH**: Using `which arrow`

## How It Works

1. The plugin receives the package context from Swift Package Manager
2. It locates the `arrow` binary using the priority order described above
3. Invokes the Arrow generator for the entire package:
   - Command: `arrow generate --is-package --package-sources-path <path>`
   - The `<path>` defaults to the plugin's work directory Sources folder
   - Captures output and reports generation status
4. Generated code is written to `dependencies.generated.swift` in your package

## Generated Output

The plugin generates:
- File: `dependencies.generated.swift`
- Location: Package source directory
- Content: Dependency injection container code based on your Arrow annotations

## Troubleshooting

### Error: Arrow binary not found

If you see an error about the arrow binary not being found:

1. Verify `arrow` is installed: `which arrow`
2. If not in PATH, specify the location:
   - Use `--arrow-path` argument, or
   - Set `ARROW_PATH` environment variable
3. Ensure the binary has execute permissions

### Error: Generation failed

If code generation fails:

1. Check that your source code has valid Arrow annotations
2. Review the error output from the `arrow` binary
3. Verify that all target dependencies are properly configured
4. Ensure write permissions exist for the target directories

## Requirements

- Swift 6.2 or later (tools version)
- Swift Package Manager
- Arrow code generator binary (installed separately)
- macOS 10.15 or later (or other Swift-supported platform)

## Plugin Capabilities

This plugin:
- Requires **write permissions** to the package directory (to generate `dependencies.generated.swift`)
- Operates as a **command plugin** with verb `arrow-generator`
- Integrates seamlessly with Swift Package Manager's plugin system
- Supports flexible binary location configuration (PATH, environment variable, or explicit path)

## Contributing

Contributions are welcome! For the main Arrow Generator tool, see the [Arrow Generator Contributing Guide](https://github.com/AhmedOsman00/arrow-generator/blob/main/docs/CONTRIBUTING.md).

For plugin-specific contributions, follow the same guidelines. The plugin is a lightweight wrapper around the Arrow Generator binary.

## Links

- [Arrow Dependency Injection Generator](https://github.com/AhmedOsman00/arrow-generator)
- [Swift Package Manager Plugins Documentation](https://github.com/apple/swift-package-manager/blob/main/Documentation/Plugins.md)
