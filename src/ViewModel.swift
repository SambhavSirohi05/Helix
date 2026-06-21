import SwiftUI
import Combine

class HelixViewModel: ObservableObject {
    @Published var bottles: [Bottle] = []
    @Published var selectedBottleId: UUID? = nil
    
    // Global Settings
    @Published var winePath: String = ""
    @Published var showingSettings = false
    
    // Onboarding and Tutorial
    @Published var showingOnboarding = false
    @Published var currentOnboardingStep = 0
    
    // Bottle Creation
    @Published var showingCreateBottle = false
    @Published var newBottleName = ""
    @Published var newBottleArch = "WoW64" // Default WoW64
    
    // State indicators
    @Published var isDownloadingWine = false
    @Published var downloadProgress: Double = 0.0
    @Published var isCreatingBottle = false
    @Published var statusMessage = ""
    
    // Add App Shortcut Modal
    @Published var showingAddShortcut = false
    @Published var newShortcutName = ""
    @Published var newShortcutExe = ""
    @Published var newShortcutArgs = ""
    
    var selectedBottle: Bottle? {
        guard let id = selectedBottleId else { return nil }
        return bottles.first(where: { $0.id == id })
    }
}
