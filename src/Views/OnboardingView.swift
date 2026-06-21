import SwiftUI

struct OnboardingView: View {
    @ObservedObject var vm: HelixViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { vm.showingOnboarding = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
            
            // Content based on step (Replaces TabView to maintain macOS compatibility)
            Group {
                if vm.currentOnboardingStep == 0 {
                    // Step 1: Welcome
                    VStack(spacing: 15) {
                        Image(systemName: "circle.grid.3x3.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 10)
                        
                        Text("Welcome to Helix")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Helix is a user-friendly bridge designed to run Windows games and apps natively on your Mac at peak performance.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else if vm.currentOnboardingStep == 1 {
                    // Step 2: Create a Bottle
                    VStack(spacing: 15) {
                        Image(systemName: "cylinder.split.1x2.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.purple)
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 10)
                        
                        Text("Create a 'Bottle'")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("A Bottle is an isolated Windows environment (prefix). Click the '+' button in the sidebar to create one, name it, and select your settings.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else if vm.currentOnboardingStep == 2 {
                    // Step 3: Run your Games
                    VStack(spacing: 15) {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .frame(width: 90, height: 70)
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 10)
                        
                        Text("Install & Launch Games")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Inside your Bottle, click 'Run EXE...' to launch an installer. Once installed, Helix lets you save shortcuts for quick launches next time!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Step 4: Graphics Options
                    VStack(spacing: 15) {
                        Image(systemName: "bolt.shield.fill")
                            .resizable()
                            .frame(width: 70, height: 85)
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 10)
                        
                        Text("Graphics and HUD")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Toggle DXVK/VKD3D for high-quality graphics translation to Apple Metal, or turn on the Performance HUD to track your FPS in real-time.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .frame(height: 280)
            
            // Navigation dots / buttons
            HStack {
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(vm.currentOnboardingStep == index ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                vm.currentOnboardingStep = index
                            }
                    }
                }
                
                Spacer()
                
                if vm.currentOnboardingStep < 3 {
                    Button(action: { vm.currentOnboardingStep += 1 }) {
                        Text("Next")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: { vm.showingOnboarding = false }) {
                        Text("Let's Go!")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 35)
        }
        .frame(width: 500, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
