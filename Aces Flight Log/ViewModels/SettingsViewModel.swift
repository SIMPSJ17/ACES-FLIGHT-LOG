import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class SettingsViewModel: ObservableObject {
    @Published var cmstatus: String
    @Published var bday: Date
    @Published var semithrsmin: String
    @Published var seminhrsmin: String
    @Published var seminghrsmin: String
    @Published var seminshrsmin: String
    @Published var semihwxhrsmin: String
    @Published var semifronthrsmin: String
    @Published var semibackhrsmin: String
    @Published var asimhrsmin: String
    @Published var asimfronthrsmin: String
    @Published var asimbackhrsmin: String
    @Published var acft: String
    @Published var user: User?
    @Published var userEmail: String
    @Published var DBversion: Int
    @Published var displayedbday: String
    
    init() {
        self.cmstatus = SettingsManager.shared.cmstatus ?? "RCM"
        self.bday = SettingsManager.shared.birthday ?? Date()
        self.semithrsmin = "\(SettingsManager.shared.semithrs)"
        self.seminhrsmin = "\(SettingsManager.shared.seminhrs)"
        self.seminghrsmin = "\(SettingsManager.shared.seminghrs)"
        self.seminshrsmin = "\(SettingsManager.shared.seminshrs)"
        self.semihwxhrsmin = "\(SettingsManager.shared.semihwxhrs)"
        self.semifronthrsmin = "\(SettingsManager.shared.semifronthrs)"
        self.semibackhrsmin = "\(SettingsManager.shared.semibackhrs)"
        self.asimhrsmin = "\(SettingsManager.shared.asimhrs)"
        self.asimfronthrsmin = "\(SettingsManager.shared.asimfronthrs)"
        self.asimbackhrsmin = "\(SettingsManager.shared.asimbackhrs)"
        self.acft = SettingsManager.shared.aircraft ?? "UH-60M"
        self.userEmail = ""
        self.displayedbday = "\(SettingsManager.shared.birthday ?? Date())"
        self.DBversion = SettingsManager.shared.DBversion
        fetchUser()//need this to be an int
    }
    
    func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        // Set the email directly from Firebase Authentication
        self.userEmail = currentUser.email ?? ""
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                if let id = data["id"] as? String,
                   let name = data["name"] as? String {
                    self?.user = User(id: id,
                                      name: name,
                                      email: self?.userEmail ?? "No email available",
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
    private let DBversionKey = "UserDBversion"
    
    private init() {
        // Set default values if not already set
        if defaults.object(forKey: birthdayKey) == nil {
            defaults.set(Date(), forKey: birthdayKey) // Set default date
        }
        if defaults.string(forKey: cmStatusKey) == nil {
            defaults.set("RCM", forKey: cmStatusKey) // Set default cm status
        }
        if defaults.string(forKey: aircraftKey) == nil {
            defaults.set("UH-60M", forKey: aircraftKey) // Set default aircraft
        }
        if defaults.integer(forKey: semithrsKey) == 0 {
            defaults.set(48, forKey: semithrsKey) // Set default semithrs
        }
        if defaults.integer(forKey: seminhrsKey) == 0 {
            defaults.set(1, forKey: seminhrsKey) // Set default seminhrs
        }
        if defaults.integer(forKey: seminghrsKey) == 0 {
            defaults.set(9, forKey: seminghrsKey) // Set default seminghrs
        }
        if defaults.integer(forKey: seminshrsKey) == 0 {
            defaults.set(9, forKey: seminshrsKey) // Set default seminshrs
        }
        if defaults.integer(forKey: semihwxhrsKey) == 0 {
            defaults.set(3, forKey: semihwxhrsKey) // Set default semihwxhrs
        }
        if defaults.integer(forKey: semifronthrsKey) == 0 {
            defaults.set(15, forKey: semifronthrsKey) // Set default semifronthrs
        }
        if defaults.integer(forKey: semibackhrsKey) == 0 {
            defaults.set(15, forKey: semibackhrsKey) // Set default semibackhrs
        }
        if defaults.integer(forKey: asimhrsKey) == 0 {
            defaults.set(12, forKey: asimhrsKey) // Set default asimhrs
        }
        if defaults.integer(forKey: asimfronthrsKey) == 0 {
            defaults.set(15, forKey: asimfronthrsKey) // Set default asimfronthrs
        }
        if defaults.integer(forKey: asimbackhrsKey) == 0 {
            defaults.set(15, forKey: asimbackhrsKey) // Set default asimbackhrs
        }
    }
    
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
        get {
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
    var DBversion: Int {
        get {
            return defaults.integer(forKey: DBversionKey)
        }
        set {
            defaults.set(newValue, forKey: DBversionKey)
        }
    }
}
