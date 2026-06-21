import SwiftUI

struct ContentView: View {
    @StateObject var vm = HelixViewModel()
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack {
                // Top status and onboarding trigger
                HStack {
                    Text("HELIX")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: { vm.showingOnboarding = true }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("How to use Helix")
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                // Sidebar List of Bottles
                List(selection: $vm.selectedBottleId) {
                    Section(header: Text("My Bottles")) {
                        ForEach(vm.bottles) { bottle in
                            NavigationLink(
                                destination: Group {
                                    if let id = vm.selectedBottleId {
                                        BottleDetailView(
                                            vm: vm,
                                            bottleId: id,
                                            onUpdate: saveBottles,
                                            onDelete: { deleteBottle(bottle) }
                                        )
                                    } else {
                                        welcomeView
                                    }
                                },
                                tag: bottle.id,
                                selection: $vm.selectedBottleId
                            ) {
                                HStack {
                                    Image(systemName: "cylinder.split.1x2.fill")
                                        .foregroundColor(.purple)
                                    Text(bottle.name)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                
                Spacer()
                
                // Add Bottle & Settings at bottom
                Divider()
                
                HStack {
                    Button(action: { vm.showingCreateBottle = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Bottle")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(10)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: { vm.showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(10)
                }
            }
            .frame(minWidth: 200, idealWidth: 220)
            
            // Main Panel Detail (Welcome View default)
            welcomeView
        }
        .frame(minWidth: 750, minHeight: 500)
        .sheet(isPresented: $vm.showingOnboarding) {
            OnboardingView(vm: vm)
        }
        .sheet(isPresented: $vm.showingCreateBottle) {
            createBottleSheet
        }
        .sheet(isPresented: $vm.showingSettings) {
            settingsSheet
        }
        .overlay(downloadOverlay)
        .overlay(creatingBottleOverlay)
        .onAppear {
            setupInitialState()
        }
        .onReceive(Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()) { _ in
            if vm.winePath.isEmpty && BackendService.shared.isWineInstalled {
                vm.winePath = BackendService.shared.installedWinePath
                saveSettings()
            }
        }
    }
    
    // Welcome / Initial State View
    var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "circle.grid.3x3.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.8))
                .padding(.bottom, 10)
            
            Text("Welcome to Helix")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
            
            Text("Ready to run Windows games natively on your Mac?")
                .font(.title3)
                .foregroundColor(.secondary)
            
            if !BackendService.shared.isWineInstalled && vm.winePath.isEmpty {
                VStack(spacing: 15) {
                    Text("Wine dependencies are required to run Windows apps.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Install Wine via App (Recommended)") {
                        installWine()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("Or run this command in your Mac Terminal app:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                    
                    Text("brew install --cask wine-stable")
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .textSelection(.enabled)
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Text("To start, create a new Bottle using the '+' button at the bottom of the sidebar.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Create a Bottle") {
                        vm.showingCreateBottle = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // Create Bottle Popover
    var createBottleSheet: some View {
        VStack(spacing: 20) {
            Text("Create New Bottle")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Bottle Name")
                TextField("E.g. Steam Games, RPGs, etc.", text: $vm.newBottleName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Architecture")
                Picker("Arch", selection: $vm.newBottleArch) {
                    Text("WoW64 (Recommended for old & new games)").tag("WoW64")
                    Text("64-Bit Only").tag("Win64")
                }
                .pickerStyle(RadioGroupPickerStyle())
            }
            .frame(width: 350)
            
            HStack {
                Button("Cancel") {
                    vm.showingCreateBottle = false
                }
                
                Spacer()
                
                Button("Create") {
                    guard !vm.newBottleName.isEmpty else { return }
                    createBottle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.newBottleName.isEmpty)
            }
        }
        .padding(25)
    }
    
    // Settings Sheet
    var settingsSheet: some View {
        VStack(spacing: 20) {
            Text("Helix Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Wine Binary Configuration")
                    .fontWeight(.medium)
                
                TextField("Path to wine64 binary", text: $vm.winePath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Browse...") {
                        let openPanel = NSOpenPanel()
                        openPanel.allowsMultipleSelection = false
                        openPanel.canChooseDirectories = false
                        openPanel.canChooseFiles = true
                        
                        if openPanel.runModal() == .OK, let url = openPanel.url {
                            vm.winePath = url.path
                            saveSettings()
                        }
                    }
                    
                    Spacer()
                    
                    if !BackendService.shared.isWineInstalled {
                        Button("Install Wine") {
                            vm.showingSettings = false
                            installWine()
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Default Bottles Path:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(BackendService.shared.defaultBottlesDir.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 400)
            
            HStack {
                Spacer()
                Button("Close") {
                    vm.showingSettings = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(25)
    }
    
    // Download/Installation overlay loader
    var downloadOverlay: some View {
        Group {
            if vm.isDownloadingWine {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("Installing Wine via Homebrew...")
                        .font(.headline)
                    Text("Executing: brew install --cask --no-quarantine wine-stable\nThis may take several minutes depending on network speed.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(30)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }
    
    // Prefix creation loader
    var creatingBottleOverlay: some View {
        Group {
            if vm.isCreatingBottle {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text(vm.statusMessage)
                        .font(.headline)
                    Text("Creating directory structure and Windows registries...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(30)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }
    
    // Initial Setup loading data
    func setupInitialState() {
        // Load settings
        if let data = try? Data(contentsOf: BackendService.shared.appSupportDir.appendingPathComponent("settings.json")),
           let settings = try? JSONDecoder().decode(HelixSettings.self, from: data) {
            vm.winePath = settings.winePath
        }
        
        // Auto-detect installed Wine if no path is configured
        if vm.winePath.isEmpty && BackendService.shared.isWineInstalled {
            vm.winePath = BackendService.shared.installedWinePath
            saveSettings()
        }
        
        // Load bottles
        if let data = try? Data(contentsOf: BackendService.shared.appSupportDir.appendingPathComponent("bottles.json")),
           let list = try? JSONDecoder().decode([Bottle].self, from: data) {
            vm.bottles = list
        }
        
        // Check if we should show onboarding
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasShownOnboarding") {
            vm.showingOnboarding = true
            userDefaults.set(true, forKey: "hasShownOnboarding")
        }
    }
    
    // Save bottles to JSON
    func saveBottles() {
        if let data = try? JSONEncoder().encode(vm.bottles) {
            try? data.write(to: BackendService.shared.appSupportDir.appendingPathComponent("bottles.json"))
        }
    }
    
    // Save settings to JSON
    func saveSettings() {
        let settings = HelixSettings(winePath: vm.winePath, isConfigured: !vm.winePath.isEmpty)
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: BackendService.shared.appSupportDir.appendingPathComponent("settings.json"))
        }
    }
    
    // Install Wine helper via Homebrew
    func installWine() {
        vm.isDownloadingWine = true
        
        BackendService.shared.installWineViaBrew { result in
            vm.isDownloadingWine = false
            switch result {
            case .success(let path):
                vm.winePath = path
                saveSettings()
            case .failure(let error):
                let alert = NSAlert()
                alert.messageText = "Installation Failed"
                
                var desc = error.localizedDescription
                if desc.contains("sudo: a password is required") || desc.contains("terminal is required to read the password") {
                    desc = "Wine installation requires administrator permissions to set up GStreamer dependencies.\n\nPlease open your macOS Terminal.app and run the following command to complete the setup:\n\nbrew install --cask wine-stable"
                }
                
                alert.informativeText = desc
                alert.alertStyle = .critical
                alert.runModal()
            }
        }
    }
    
    // Create new Bottle prefix
    func createBottle() {
        guard !vm.winePath.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "Wine Not Found"
            alert.informativeText = "Please download or configure a path to your Wine binary in settings first."
            alert.runModal()
            return
        }
        
        vm.showingCreateBottle = false
        vm.isCreatingBottle = true
        vm.statusMessage = "Initializing Bottle '\(vm.newBottleName)'..."
        
        let bottleFolder = BackendService.shared.defaultBottlesDir.appendingPathComponent(vm.newBottleName.replacingOccurrences(of: " ", with: "_"))
        
        BackendService.shared.createPrefix(at: bottleFolder.path, winePath: vm.winePath) { success in
            vm.isCreatingBottle = false
            if success {
                let bottle = Bottle(
                    name: vm.newBottleName,
                    path: bottleFolder.path,
                    arch: vm.newBottleArch
                )
                vm.bottles.append(bottle)
                saveBottles()
                vm.selectedBottleId = bottle.id
            } else {
                let alert = NSAlert()
                alert.messageText = "Initialization Failed"
                alert.informativeText = "Failed to initialize the prefix. Make sure your Wine path is valid."
                alert.runModal()
            }
            vm.newBottleName = ""
        }
    }
    
    // Delete Bottle prefix
    func deleteBottle(_ bottle: Bottle) {
        let alert = NSAlert()
        alert.messageText = "Delete Bottle"
        alert.informativeText = "Are you sure you want to delete '\(bottle.name)'? This will permanently delete all contents inside the bottle prefix."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Delete")
        
        if alert.runModal() == .alertSecondButtonReturn {
            // Delete folder
            try? FileManager.default.removeItem(atPath: bottle.path)
            
            // Remove from state
            vm.bottles.removeAll { $0.id == bottle.id }
            saveBottles()
            vm.selectedBottleId = nil
        }
    }
}
