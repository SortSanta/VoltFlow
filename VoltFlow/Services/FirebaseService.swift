import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    init() {
        print("FirebaseService: Initializing...")
        setupFirebaseAuthStateListener()
    }
    
    private func setupFirebaseAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    print("FirebaseService: User authenticated with ID: \(user.uid)")
                    self?.isAuthenticated = true
                    self?.fetchUser(userId: user.uid)
                } else {
                    print("FirebaseService: No user authenticated")
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - User Management
    
    func fetchUser(userId: String) {
        print("FirebaseService: Fetching user with ID: \(userId)")
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("FirebaseService: Error fetching user: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                do {
                    let user = try Firestore.Decoder().decode(User.self, from: data)
                    print("FirebaseService: Successfully fetched user: \(user.email)")
                    DispatchQueue.main.async {
                        self?.currentUser = user
                    }
                } catch {
                    print("FirebaseService: Failed to decode user data: \(error.localizedDescription)")
                }
            } else {
                print("FirebaseService: No user data found in Firestore")
            }
        }
    }
    
    func createUser(email: String) async throws {
        print("FirebaseService: Creating new user with email: \(email)")
        guard let authUser = Auth.auth().currentUser else {
            print("FirebaseService: No authenticated user found when creating user")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        let newUser = User(
            id: authUser.uid,
            email: email,
            createdAt: Date(),
            cars: [],
            favoriteStations: [],
            preferences: User.Preferences(
                defaultChargingSpeed: .normal,
                preferredPaymentMethod: nil,
                notificationsEnabled: true,
                darkModeEnabled: true
            )
        )
        
        do {
            try await db.collection("users").document(authUser.uid).setData(from: newUser)
            print("FirebaseService: Successfully created user in Firestore")
            DispatchQueue.main.async {
                self.currentUser = newUser
                self.isAuthenticated = true
            }
        } catch {
            print("FirebaseService: Error creating user in Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String) async throws {
        print("FirebaseService: Attempting to sign up with email: \(email)")
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("FirebaseService: Successfully created auth user with ID: \(result.user.uid)")
            try await createUser(email: email)
        } catch {
            print("FirebaseService: Sign up failed with error: \(error.localizedDescription)")
            if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
                switch errorCode {
                case .emailAlreadyInUse:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email is already in use"])
                case .invalidEmail:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email format"])
                case .weakPassword:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password is too weak. Please use at least 6 characters"])
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("FirebaseService: Attempting to sign in with email: \(email)")
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("FirebaseService: Successfully signed in user with ID: \(result.user.uid)")
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            print("FirebaseService: Sign in failed with error: \(error.localizedDescription)")
            if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
                switch errorCode {
                case .wrongPassword:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Incorrect password"])
                case .userNotFound:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No account found with this email"])
                case .invalidEmail:
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email format"])
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    func signOut() throws {
        print("FirebaseService: Attempting to sign out")
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            print("FirebaseService: Successfully signed out")
        } catch {
            print("FirebaseService: Sign out failed with error: \(error.localizedDescription)")
            throw error
        }
    }
}
