import SwiftUI

struct BottleDetailView: View {
    @ObservedObject var vm: HelixViewModel
    var bottleId: UUID
    var onUpdate: () -> Void
    var onDelete: () -> Void
    
    var bottleIndex: Int? {
        vm.bottles.firstIndex(where: { $0.id == bottleId })
    }
    
    var body: some View {
        Group {
            if let idx = bottleIndex {
                let bottle = vm.bottles[idx]
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(bottle.name)
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text("Prefix: \(bottle.path)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: onDelete) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Bottle")
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // System Tools Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Control Panel & Configuration")
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                Button(action: { BackendService.shared.launchUtility(bottle: bottle, winePath: vm.winePath, utilityName: "winecfg") }) {
                                    Label("Wine Config", systemImage: "slider.horizontal.3")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { BackendService.shared.launchUtility(bottle: bottle, winePath: vm.winePath, utilityName: "regedit") }) {
                                    Label("Registry Editor", systemImage: "square.grid.2x2.fill")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { BackendService.shared.launchUtility(bottle: bottle, winePath: vm.winePath, utilityName: "control") }) {
                                    Label("Control Panel", systemImage: "gearshape.2.fill")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { 
                                    let driveC = URL(fileURLWithPath: bottle.path).appendingPathComponent("drive_c")
                                    NSWorkspace.shared.open(driveC)
                                }) {
                                    Label("C: Drive", systemImage: "folder.fill")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Settings & Toggles
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Graphics & Performance Settings")
                                .font(.headline)
                            
                            VStack(spacing: 12) {
                                Toggle(isOn: Binding(
                                    get: { vm.bottles[idx].dxvkEnabled },
                                    set: { vm.bottles[idx].dxvkEnabled = $0; onUpdate() }
                                )) {
                                    VStack(alignment: .leading) {
                                        Text("Enable DXVK")
                                            .fontWeight(.medium)
                                        Text("Translates Direct3D 9/10/11 to Vulkan (Metal). Essential for modern games.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                Toggle(isOn: Binding(
                                    get: { vm.bottles[idx].vkd3dEnabled },
                                    set: { vm.bottles[idx].vkd3dEnabled = $0; onUpdate() }
                                )) {
                                    VStack(alignment: .leading) {
                                        Text("Enable VKD3D")
                                            .fontWeight(.medium)
                                        Text("Translates Direct3D 12 to Vulkan (Metal) for DX12 titles.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                Toggle(isOn: Binding(
                                    get: { vm.bottles[idx].hudEnabled },
                                    set: { vm.bottles[idx].hudEnabled = $0; onUpdate() }
                                )) {
                                    VStack(alignment: .leading) {
                                        Text("Performance HUD")
                                            .fontWeight(.medium)
                                        Text("Displays real-time FPS overlay during games.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                Toggle(isOn: Binding(
                                    get: { vm.bottles[idx].esyncEnabled },
                                    set: { vm.bottles[idx].esyncEnabled = $0; onUpdate() }
                                )) {
                                    VStack(alignment: .leading) {
                                        Text("Enable ESYNC")
                                            .fontWeight(.medium)
                                        Text("High-performance multi-threading optimization.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            .cornerRadius(10)
                        }
                        
                        // Application Shortcuts
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Application Shortcuts")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: { selectAndRunEXE(bottle: bottle) }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("Run EXE...")
                                    }
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { vm.showingAddShortcut = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Add Shortcut")
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if bottle.shortcuts.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "questionmark.folder")
                                        .font(.system(size: 30))
                                        .foregroundColor(.secondary)
                                    Text("No shortcuts added yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(bottle.shortcuts) { shortcut in
                                        HStack {
                                            Image(systemName: "doc.fill")
                                                .foregroundColor(.blue)
                                            
                                            VStack(alignment: .leading) {
                                                Text(shortcut.name)
                                                    .fontWeight(.medium)
                                                Text(shortcut.exePath)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            Button("Launch") {
                                                BackendService.shared.launchExecutable(
                                                    bottle: bottle,
                                                    winePath: vm.winePath,
                                                    exePath: shortcut.exePath,
                                                    arguments: shortcut.arguments
                                                )
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .controlSize(.small)
                                            
                                            Button(action: {
                                                vm.bottles[idx].shortcuts.removeAll { $0.id == shortcut.id }
                                                onUpdate()
                                            }) {
                                                Image(systemName: "xmark.circle")
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding()
                                        .background(Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(30)
                }
                .sheet(isPresented: $vm.showingAddShortcut) {
                    VStack(spacing: 20) {
                        Text("Add Application Shortcut")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Shortcut Name")
                            TextField("E.g. Steam, Cyberpunk, etc.", text: $vm.newShortcutName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Executable Path (.exe)")
                            HStack {
                                TextField("Path to .exe file", text: $vm.newShortcutExe)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Browse...") {
                                    let openPanel = NSOpenPanel()
                                    openPanel.allowsMultipleSelection = false
                                    openPanel.canChooseDirectories = false
                                    openPanel.canChooseFiles = true
                                    openPanel.allowedContentTypes = [.exe]
                                    
                                    if openPanel.runModal() == .OK, let url = openPanel.url {
                                        vm.newShortcutExe = url.path
                                        if vm.newShortcutName.isEmpty {
                                            vm.newShortcutName = url.deletingPathExtension().lastPathComponent
                                        }
                                    }
                                }
                            }
                            
                            Text("Arguments (Optional)")
                            TextField("E.g. -windowed -novid", text: $vm.newShortcutArgs)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(width: 400)
                        
                        HStack {
                            Button("Cancel") {
                                vm.showingAddShortcut = false
                            }
                            
                            Spacer()
                            
                            Button("Add") {
                                guard !vm.newShortcutName.isEmpty && !vm.newShortcutExe.isEmpty else { return }
                                let shortcut = AppShortcut(name: vm.newShortcutName, exePath: vm.newShortcutExe, arguments: vm.newShortcutArgs)
                                vm.bottles[idx].shortcuts.append(shortcut)
                                onUpdate()
                                
                                // Clear fields and close
                                vm.newShortcutName = ""
                                vm.newShortcutExe = ""
                                vm.newShortcutArgs = ""
                                vm.showingAddShortcut = false
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.newShortcutName.isEmpty || vm.newShortcutExe.isEmpty)
                        }
                        .padding(.top, 10)
                    }
                    .padding(25)
                }
            } else {
                VStack {
                    Text("Loading details...")
                }
            }
        }
    }
    
    // Open panel to browse and run EXE directly
    func selectAndRunEXE(bottle: Bottle) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.exe]
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            BackendService.shared.launchExecutable(
                bottle: bottle,
                winePath: vm.winePath,
                exePath: url.path,
                arguments: ""
            )
        }
    }
}
