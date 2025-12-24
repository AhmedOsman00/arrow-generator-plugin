# Contributing to Arrow Generator Plugin

Thank you for your interest in contributing to the Arrow Generator Plugin! This guide will help you get started with development.

## Development

### Building the Plugin

```bash
swift build
```

### Testing Locally

To test the plugin in a Swift package that uses it:

```bash
# Use arrow from system PATH
swift package plugin arrow-generator

# Specify custom arrow binary path
swift package plugin arrow-generator --arrow-path /path/to/arrow

# Or use environment variable
ARROW_PATH=/path/to/arrow swift package plugin arrow-generator
```

### Cleaning Build Artifacts

```bash
swift package clean
```

### Resolving Dependencies

```bash
swift package resolve
```

## Important: Constants Synchronization

⚠️ **CRITICAL**: When making changes to the plugin, the `PluginConstants` structure must be kept in sync across three locations:

1. `Plugins/ArrowGeneratorPlugin/ArrowGeneratorPlugin.swift:7-15`
2. `Sources/Constants/Constants.swift` (in arrow-generator repo)
3. `Package.swift` (plugin configuration)

**When modifying any of the following, update all three locations:**
- Command-line arguments
- Flags
- Executable names
- Environment variables

## Plugin Architecture

### Key Components

1. **Plugin Entry Point** (`Plugins/ArrowGeneratorPlugin/ArrowGeneratorPlugin.swift`)
   - Main plugin implementation conforming to `CommandPlugin`
   - `performCommand()`: Orchestrates generation for all package targets
   - `findArrowBinary()`: Locates the `arrow` executable using a priority order

2. **Binary Discovery**: The plugin searches for the `arrow` binary in this priority order:
   - Command-line argument: `--arrow-path /path/to/arrow`
   - Environment variable: `ARROW_PATH`
   - System PATH: Using `/usr/bin/which arrow`

3. **Generation Flow**:
   - Plugin receives package context from SPM
   - Iterates through each source module target
   - Invokes `arrow generate --is-package --package-name <target> --package-sources-path <path>` for each target
   - Captures stdout/stderr and reports generation status

## Error Handling

The plugin has two main error cases:

1. **Arrow binary not found** (`PluginError.arrowNotFound`): Thrown when `which arrow` fails to locate the binary
2. **Generation failed** (`PluginError.generationFailed`): Thrown when the arrow binary exits with non-zero status

Both errors provide detailed error messages to guide users on resolution.

## Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly using the commands above
5. Ensure constants are synchronized if you modified them
6. Submit a pull request with a clear description of your changes

## Code Style

- Follow Swift API Design Guidelines
- Use clear, descriptive variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose

## Testing

Before submitting a pull request:
- Test the plugin with a sample Swift package
- Verify it works with arrow binary in PATH
- Verify it works with `--arrow-path` argument
- Verify it works with `ARROW_PATH` environment variable
- Test error cases (missing binary, generation failures)

## Questions?

If you have questions or need help, please open an issue in the repository.
