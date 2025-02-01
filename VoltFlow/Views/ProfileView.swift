import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var firebaseService: FirebaseService
    @State private var showingSignOutAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                Section {
                    if let user = firebaseService.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.email)
                                    .font(.headline)
                                Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // App Settings
                Section("App Settings") {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }
                
                // Car Settings
                Section("Car Settings") {
                    NavigationLink {
                        Text("Car Management") // Placeholder for car management view
                    } label: {
                        Label("Manage Cars", systemImage: "car.fill")
                    }
                    
                    NavigationLink {
                        Text("Charging Preferences") // Placeholder for charging preferences view
                    } label: {
                        Label("Charging Preferences", systemImage: "bolt.car.fill")
                    }
                }
                
                // Account Settings
                Section("Account") {
                    NavigationLink {
                        Text("Account Settings") // Placeholder for account settings view
                    } label: {
                        Label("Account Settings", systemImage: "person.fill")
                    }
                    
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                // About Section
                Section("About") {
                    NavigationLink {
                        Text("Help & Support") // Placeholder for help view
                    } label: {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy") // Placeholder for privacy policy view
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    NavigationLink {
                        Text("Terms of Service") // Placeholder for terms view
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signOut() {
        do {
            try firebaseService.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(FirebaseService.shared)
}
