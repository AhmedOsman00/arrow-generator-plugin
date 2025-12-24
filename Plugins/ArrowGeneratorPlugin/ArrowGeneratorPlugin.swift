import PackagePlugin
import Foundation

// ⚠️ SYNC: Keep in sync with:
// - arrow-generator/Sources/Constants/Constants.swift
private enum PluginConstants {
    static let executableTargetName = "arrow"
    static let isPackageFlag = "is-package"
    static let packageSourcesPathArgument = "package-sources-path"
    static let arrowPathArgument = "arrow-path"
    static let generateCommand = "generate"
    static let arrowPathEnvVariable = "ARROW_PATH"
}

@main
struct ArrowGeneratorPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let arrowPath = try findArrowBinary(arguments: arguments)
        let packageName = context.package.displayName
        let sourcesPath = getSourcesPath(context: context, arguments: arguments)

        let arguments = [
            PluginConstants.generateCommand,
            "--\(PluginConstants.isPackageFlag)",
            "--\(PluginConstants.packageSourcesPathArgument)", sourcesPath,
        ]

        print("Generating dependency container for \(packageName)...")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: arrowPath)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
            print(output)
        }

        if process.terminationStatus != 0 {
            if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
                print("Error: \(error)")
            }
            throw PluginError.generationFailed(packageName: packageName, exitCode: process.terminationStatus)
        }

        print("✓ Generated dependencies.generated.swift for \(packageName)")
    }

    private func getSourcesPath(context: PluginContext, arguments: [String]) -> String {
        if let sourcesPathIndex = arguments.firstIndex(where: { $0 == "--\(PluginConstants.packageSourcesPathArgument)" }),
            sourcesPathIndex + 1 < arguments.count {
            let path = arguments[sourcesPathIndex + 1]
            if !path.isEmpty {
                return path
            }
        }
        return context.pluginWorkDirectoryURL.appending(path: "Sources").absoluteString
    }

    private func findArrowBinary(arguments: [String]) throws -> String {
        // 1. Check command-line arguments for --arrow-path
        if let arrowPathIndex = arguments.firstIndex(where: { $0 == "--\(PluginConstants.arrowPathArgument)" }),
           arrowPathIndex + 1 < arguments.count {
            let path = arguments[arrowPathIndex + 1]
            if !path.isEmpty {
                return path
            }
        }

        // 2. Check environment variable ARROW_PATH
        if let envPath = ProcessInfo.processInfo.environment[PluginConstants.arrowPathEnvVariable],
           !envPath.isEmpty {
            return envPath
        }

        // 3. Search for binary in PATH using which
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = [PluginConstants.executableTargetName]

        let pipe = Pipe()
        whichProcess.standardOutput = pipe

        try? whichProcess.run()
        whichProcess.waitUntilExit()

        if whichProcess.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty {
                return path
            }
        }

        throw PluginError.arrowNotFound
    }

    enum PluginError: LocalizedError {
        case arrowNotFound
        case generationFailed(packageName: String, exitCode: Int32)

        var errorDescription: String? {
            switch self {
            case .arrowNotFound:
                return """
                Arrow binary not found!

                Please install the arrow binary by:
                  cd /path/to/arrow-generator && make build && sudo cp bin/arrow /usr/local/bin/

                Or set the ARROW_PATH environment variable to point to the arrow binary.
                
                Or pass argument arrow-path with the arrow binary.
                """
            case let .generationFailed(packageName, exitCode):
                return "Failed to generate dependencies for \(packageName) (exit code: \(exitCode))"
            }
        }
    }
}
