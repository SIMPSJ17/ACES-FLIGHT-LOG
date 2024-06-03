import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class SettingsViewModel: ObservableObject {
    @Published var cmstatus: String = "RCM"
    @Published var bday = Date()
    @Published var semithrsmin = "48"
    @Published var seminhrsmin = "1"
    @Published var seminghrsmin = "9"
    @Published var seminshrsmin = "9"
    @Published var semihwxhrsmin = "3"
    @Published var semifronthrsmin = "15"
    @Published var semibackhrsmin = "15"
    @Published var asimhrsmin = "12"
    @Published var asimfronthrsmin = "15"
    @Published var asimbackhrsmin = "15"
    @Published var acft: String = "\(SettingsManager.shared.aircraft ?? "UH-60M")"
    @Published var user: User? = nil
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                if let id = data["id"] as? String,
                   let name = data["name"] as? String,
                   let email = data["email"] as? String {
                    self?.user = User(id: id,
                                      name: name,
                                      email: email,
                                      joined: data["joined"] as? TimeInterval ?? 0)
                } else {
                    print("Error: User data is missing or invalid.")
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "DeleteAccount", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userId)
        
        // Delete Firestore user document
        userDocRef.delete { [weak self] error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Delete Firebase Auth user
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    completion(.failure(error))
                    return print()
                }
                
                // Logout after successful deletion
                self?.logout()
                completion(.success(()))
            }
        }
    }
}

class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    // Keys for user settings
    private let birthdayKey = "UserBirthday"
    private let cmStatusKey = "UserCMStatus"
    private let aircraftKey = "UserAircraft"
    private let semithrsKey = "Usersemithrs"
    private let seminhrsKey = "Userseminhrs"
    private let seminghrsKey = "Userseminghrs"
    private let seminshrsKey = "Userseminshrs"
    private let semifronthrsKey = "Userfronthrs"
    private let semibackhrsKey = "Userbackhrs"
    private let semihwxhrsKey = "UserAhwxhrs"
    private let asimhrsKey = "UserAsimhrs"
    private let asimfronthrsKey = "UserAsimfronthrs"
    private let asimbackhrsKey = "UserAsimbackhrs"
    
    // MARK: - User Settings Properties
    
    var birthday: Date? {
        get {
            return defaults.object(forKey: birthdayKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: birthdayKey)
        }
    }
    
    var cmstatus: String? {
        get {
            return defaults.string(forKey: cmStatusKey)
        }
        set {
            defaults.set(newValue, forKey: cmStatusKey)
        }
    }
    
    var aircraft: String? {
        get {
            return defaults.string(forKey: aircraftKey)
        }
        set {
            defaults.set(newValue, forKey: aircraftKey)
        }
    }
    
    var semithrs: Int {
        get {
            return defaults.integer(forKey: semithrsKey)
        }
        set {
            defaults.set(newValue, forKey: semithrsKey)
        }
    }
    
    var seminhrs: Int {
        get {
            return defaults.integer(forKey: seminhrsKey)
        }
        set {
            defaults.set(newValue, forKey: seminhrsKey)
        }
    }
    
    var seminghrs: Int {
        get {
            return defaults.integer(forKey: seminghrsKey)
        }
        set {
            defaults.set(newValue, forKey: seminghrsKey)
        }
    }
    
    var seminshrs: Int {
        get{
            return defaults.integer(forKey: seminshrsKey)
        }
        set {
            defaults.set(newValue, forKey: seminshrsKey)
        }
    }
    
    var semihwxhrs: Int {
        get {
            return defaults.integer(forKey: semihwxhrsKey)
        }
        set {
            defaults.set(newValue, forKey: semihwxhrsKey)
        }
    }
    var semifronthrs: Int {
        get {
            return defaults.integer(forKey: semifronthrsKey)
        }
        set {
            defaults.set(newValue, forKey: semifronthrsKey)
        }
    }
    
    var semibackhrs: Int {
        get {
            return defaults.integer(forKey: semibackhrsKey)
        }
        set {
            defaults.set(newValue, forKey: semibackhrsKey)
        }
    }
    
    var asimhrs: Int {
        get {
            return defaults.integer(forKey: asimhrsKey)
        }
        set {
            defaults.set(newValue, forKey: asimhrsKey)
        }
    }
    var asimfronthrs: Int {
        get {
            return defaults.integer(forKey: asimfronthrsKey)
        }
        set {
            defaults.set(newValue, forKey: asimfronthrsKey)
        }
    }
    var asimbackhrs: Int {
        get {
            return defaults.integer(forKey: asimbackhrsKey)
        }
        set {
            defaults.set(newValue, forKey: asimbackhrsKey)
        }
    }
}
