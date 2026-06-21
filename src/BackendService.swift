import Foundation

class BackendService {
    static let shared = BackendService()
    
    let fileManager = FileManager.default
    
    var appSupportDir: URL {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = paths[0].appendingPathComponent("Helix")
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true, attributes: nil)
        return appSupport
    }
    
    var defaultBottlesDir: URL {
        let devHelix = URL(fileURLWithPath: "/Users/sambhavsirohi/Developer/Helix")
        let bottles = devHelix.appendingPathComponent("Bottles")
        try? fileManager.createDirectory(at: bottles, withIntermediateDirectories: true, attributes: nil)
        return bottles
    }
    
    // Check if Wine is already installed in Homebrew paths
    var isWineInstalled: Bool {
        let paths = [
            "/opt/homebrew/bin/wine",
            "/opt/homebrew/bin/wine64",
            "/usr/local/bin/wine",
            "/usr/local/bin/wine64"
        ]
        for path in paths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    var installedWinePath: String {
        let paths = [
            "/opt/homebrew/bin/wine",
            "/opt/homebrew/bin/wine64",
            "/usr/local/bin/wine",
            "/usr/local/bin/wine64"
        ]
        for path in paths {
            if fileManager.fileExists(atPath: path) {
                return path
            }
        }
        return ""
    }
    
    // Execute shell command synchronously
    func runCommand(executable: String, arguments: [String], environment: [String: String] = [:]) -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        
        var env = ProcessInfo.processInfo.environment
        for (key, val) in environment {
            env[key] = val
        }
        process.environment = env
        
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
            
            let stdout = String(data: outData, encoding: .utf8) ?? ""
            let stderr = String(data: errData, encoding: .utf8) ?? ""
            
            return (process.terminationStatus, stdout, stderr)
        } catch {
            return (-1, "", error.localizedDescription)
        }
    }
    
    // Execute shell command asynchronously (for launching games)
    func runCommandAsync(executable: String, arguments: [String], environment: [String: String] = [:], workingDirectory: String? = nil) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        
        if let workDir = workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: workDir)
        }
        
        var env = ProcessInfo.processInfo.environment
        for (key, val) in environment {
            env[key] = val
        }
        process.environment = env
        
        do {
            try process.run()
        } catch {
            print("Failed to run async command: \(error)")
        }
    }
    
    // Install Wine via Homebrew Cask (Official WineHQ macOS Method)
    func installWineViaBrew(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let brewPath = "/opt/homebrew/bin/brew"
            
            // Check if brew exists
            guard self.fileManager.fileExists(atPath: brewPath) else {
                let err = NSError(domain: "Helix", code: -2, userInfo: [NSLocalizedDescriptionKey: "Homebrew was not found at /opt/homebrew/bin/brew. Please install Homebrew first."])
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            // Run brew install --cask wine-stable
            let result = self.runCommand(
                executable: brewPath,
                arguments: ["install", "--cask", "wine-stable"]
            )
            
            DispatchQueue.main.async {
                if result.status == 0 {
                    let path = self.installedWinePath
                    if !path.isEmpty {
                        completion(.success(path))
                    } else {
                        let err = NSError(domain: "Helix", code: -3, userInfo: [NSLocalizedDescriptionKey: "Wine installed successfully but 'wine64' executable could not be resolved in Homebrew paths."])
                        completion(.failure(err))
                    }
                } else {
                    let err = NSError(domain: "Helix", code: Int(result.status), userInfo: [NSLocalizedDescriptionKey: "Homebrew install failed: \(result.stderr)"])
                    completion(.failure(err))
                }
            }
        }
    }
    
    // Create new Wine prefix
    func createPrefix(at path: String, winePath: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let winebootPath = URL(fileURLWithPath: winePath).deletingLastPathComponent().appendingPathComponent("wineboot").path
            
            // Set prefix env and run wineboot -u (initializes prefix)
            let result = self.runCommand(
                executable: winebootPath,
                arguments: ["-u"],
                environment: [
                    "WINEPREFIX": path,
                    "WINEDEBUG": "-all"
                ]
            )
            
            DispatchQueue.main.async {
                completion(result.status == 0)
            }
        }
    }
    
    // Run an application in the prefix
    func launchExecutable(bottle: Bottle, winePath: String, exePath: String, arguments: String) {
        var env: [String: String] = [
            "WINEPREFIX": bottle.path,
            "WINEDEBUG": "-all"
        ]
        
        if bottle.hudEnabled {
            env["DXVK_HUD"] = "fps,gpuload"
        }
        if bottle.esyncEnabled {
            env["WINEESYNC"] = "1"
        }
        if bottle.msyncEnabled {
            env["WINEMSYNC"] = "1"
        }
        
        var overrides: [String] = []
        if bottle.dxvkEnabled {
            overrides.append(contentsOf: ["d3d9", "d3d10core", "d3d11", "dxgi"])
        }
        if bottle.vkd3dEnabled {
            overrides.append("d3d12")
        }
        if !overrides.isEmpty {
            env["WINEDLLOVERRIDES"] = overrides.map { "\($0)=n,b" }.joined(separator: ";")
        }
        
        let args = [exePath] + arguments.split(separator: " ").map(String.init)
        
        let exeURL = URL(fileURLWithPath: exePath)
        let workingDirectory = exeURL.deletingLastPathComponent().path
        
        runCommandAsync(executable: winePath, arguments: args, environment: env, workingDirectory: workingDirectory)
    }
    
    // Launch Wine utility helper
    func launchUtility(bottle: Bottle, winePath: String, utilityName: String) {
        let binDir = URL(fileURLWithPath: winePath).deletingLastPathComponent()
        let utilityPath = binDir.appendingPathComponent(utilityName).path
        
        runCommandAsync(
            executable: utilityPath,
            arguments: [],
            environment: ["WINEPREFIX": bottle.path],
            workingDirectory: binDir.path
        )
    }
}
