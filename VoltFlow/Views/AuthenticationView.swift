import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var firebaseService = FirebaseService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var rememberMe = false
    @State private var useBiometrics = false
    
    private let keychainService = KeychainService.shared
    private let biometricService = BiometricAuthService.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 30) {
                    // Logo
                    Image(systemName: "bolt.car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("VoltFlow")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Form fields
                    VStack(spacing: 20) {
                        // Email field
                        CustomTextField(
                            text: $email,
                            placeholder: "Email",
                            systemImage: "envelope.fill"
                        )
                        .disabled(isLoading)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        
                        // Password field
                        CustomTextField(
                            text: $password,
                            placeholder: "Password",
                            systemImage: "lock.fill",
                            isSecure: true
                        )
                        .disabled(isLoading)
                        
                        if isSignUp {
                            // Confirm password field for sign up
                            CustomTextField(
                                text: $confirmPassword,
                                placeholder: "Confirm Password",
                                systemImage: "lock.fill",
                                isSecure: true
                            )
                            .disabled(isLoading)
                        }
                        
                        if !isSignUp {
                            // Remember Me and Face ID options
                            HStack {
                                Toggle(isOn: $rememberMe) {
                                    Text("Remember Me")
                                        .foregroundColor(.white)
                                }
                                
                                if biometricService.biometricType != .none {
                                    Spacer()
                                    Toggle(isOn: $useBiometrics) {
                                        HStack {
                                            Image(systemName: biometricService.biometricType == .faceID ? "faceid" : "touchid")
                                            Text(biometricService.biometricType.description)
                                        }
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign In/Up button
                    Button(action: {
                        Task {
                            await handleEmailAuth()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    
                    // Toggle between Sign In/Up
                    Button(action: {
                        isSignUp.toggle()
                        password = ""
                        confirmPassword = ""
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 50)
            }
        }
        .alert("Authentication Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            Task {
                await checkSavedCredentials()
            }
        }
    }
    
    private func checkSavedCredentials() async {
        do {
            let savedEmail = try keychainService.retrieve(for: "voltflow_email")
            email = savedEmail
            
            if useBiometrics {
                do {
                    try await biometricService.authenticate()
                    let savedPassword = try keychainService.retrieve(for: "voltflow_password")
                    password = savedPassword
                    await handleEmailAuth()
                } catch {
                    print("Biometric authentication failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("No saved credentials found")
        }
    }
    
    private func handleEmailAuth() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if isSignUp {
                guard password == confirmPassword else {
                    alertMessage = "Passwords do not match"
                    showingAlert = true
                    return
                }
                try await firebaseService.signUp(email: email, password: password)
            } else {
                try await firebaseService.signIn(email: email, password: password)
                
                // Save credentials if Remember Me is enabled
                if rememberMe {
                    do {
                        try keychainService.save(email, for: "voltflow_email")
                        try keychainService.save(password, for: "voltflow_password")
                    } catch KeychainError.duplicateEntry {
                        try keychainService.update(email, for: "voltflow_email")
                        try keychainService.update(password, for: "voltflow_password")
                    }
                } else {
                    try? keychainService.delete(for: "voltflow_email")
                    try? keychainService.delete(for: "voltflow_password")
                }
            }
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

// Custom styled text field
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(PlainTextFieldStyle())
        .padding()
        .background(
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.gray)
                    .padding(.leading)
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(10)
        )
    }
}
