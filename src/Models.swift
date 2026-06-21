import Foundation

struct AppShortcut: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var exePath: String
    var arguments: String = ""
}

struct Bottle: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var path: String
    var arch: String = "WoW64" // WoW64 or Win64
    var wineVersion: String = "Wine 11.0"
    var dxvkEnabled: Bool = true
    var vkd3dEnabled: Bool = true
    var hudEnabled: Bool = false
    var esyncEnabled: Bool = true
    var msyncEnabled: Bool = false
    var shortcuts: [AppShortcut] = []
}

struct HelixSettings: Codable {
    var winePath: String = ""
    var isConfigured: Bool = false
}
