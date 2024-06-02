# ACES-FLIGHT-LOG
comaceslog.Aces-Flight-Log
ACES FLIGHT LOG

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RevenueCat
import RevenueCatUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, PurchasesDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Purchases.logLevel = .debug
        
        // Initialize RevenueCat
        Purchases.configure(withAPIKey: "appl_XfUEnHDnmPktIGRAamXRCBulLlr")
        Purchases.shared.delegate = self
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        return true
    }

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        NotificationCenter.default.post(name: .subscriptionStatusDidChange, object: customerInfo)
    }
}

extension Notification.Name {
    static let subscriptionStatusDidChange = Notification.Name("subscriptionStatusDidChange")
}

@main
struct Aces_Flight_LogApp: App {
    @StateObject var userViewModel = UserViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userViewModel) // Ensure the userViewModel is available throughout the app
        }
    }
}
import Foundation

extension Encodable {
    func asDictionary() -> [String: Any]{
        guard let data = try? JSONEncoder().encode(self) else {
            return[:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        }catch{
            return [:]
        }
    }
}

import FirebaseAuth
import Foundation

class MainViewModel: ObservableObject {
    @Published var currentUserId: String = ""

    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }

    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
import FirebaseAuth
import Foundation

class LoginViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init (){}
    
    func login() {
            guard validate() else {
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle login error
                    self.errorMessage = "Login Failed"
                } else {
                    // Login successful
                    // You can perform additional actions here, like navigating to another view
                    print("User logged in successfully!")
                }
            }
        }
        //require fields be entered
        private func validate() -> Bool{
            errorMessage = ""
            guard !email.trimmingCharacters(in:  .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else{
                errorMessage = "Please Fill in all Fields"
                return false
            }
            //
            guard email.contains("@") && email.contains(".") else {
                errorMessage = "Please enter valid Email"
                return false
            }
            return true
        }
    }
import Foundation
import FirebaseAuth

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var errorMessage = ""
    @Published var isResetSuccessful = false

    func forgotPassword() {
        guard validate() else { return }

        let auth = Auth.auth()

        auth.sendPasswordReset(withEmail: email) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isResetSuccessful = true
            }
        }
    }

    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please Provide Email"
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid Email"
            return false
        }
        return true
    }
}
import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    init() {}
    
    func register() {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            guard let userId = result?.user.uid else {
                print("User ID not found after registration.")
                return
            }
            
            self.insertUserRecord(id: userId)
            
        }
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id,
                           name: name,
                           email: email,
                           joined: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { error in
                if let error = error {
                    print("Error adding user record: \(error.localizedDescription)")
                } else {
                    print("User record added successfully.")
                }
            }
    }

    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard email.contains(".") && email.contains("@") else {
            return false
        }
        guard password.count >= 6 else {
            return false
        }
        
        return true
    }
}
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class Firestorequery: ObservableObject {
    @Published var items: [FlightLogItem] = []
    @Published var totalHours: Double = 0.0
    @Published var totalngHours: Double = 0.0
    @Published var totalnsHours: Double = 0.0
    @Published var totalwxHours: Double = 0.0
    @Published var totalfrontHours: Double = 0.0
    @Published var totalbackHours: Double = 0.0
    @Published var lastNGflight: Date?
    @Published var lastNSflight: Date?
    @Published var p1tHours: Double = 0.0
    @Published var p1ngHours: Double = 0.0
    @Published var p1nsHours: Double = 0.0
    @Published var p1hwxHours: Double = 0.0
    @Published var p1nHours: Double = 0.0
    @Published var p1frontHours: Double = 0.0
    @Published var p1backHours: Double = 0.0
    @Published var p1simHours: Double = 0.0
    @Published var p1simfrontHours: Double = 0.0
    @Published var p1simbackHours: Double = 0.0
    @Published var p1simhwxHours: Double = 0.0
    @Published var p2tHours: Double = 0.0
    @Published var p2ngHours: Double = 0.0
    @Published var p2nsHours: Double = 0.0
    @Published var p2hwxHours: Double = 0.0
    @Published var p2nHours: Double = 0.0
    @Published var p2simHours: Double = 0.0
    @Published var p2simfrontHours: Double = 0.0
    @Published var p2simbackHours: Double = 0.0
    @Published var p2simhwxHours: Double = 0.0
    @Published var p2frontHours: Double = 0.0
    @Published var p2backHours: Double = 0.0
    @Published var AtHours: Double = 0.0
    @Published var AngHours: Double = 0.0
    @Published var AnsHours: Double = 0.0
    @Published var AhwxHours: Double = 0.0
    @Published var AnHours: Double = 0.0
    @Published var AfrontHours: Double = 0.0
    @Published var AbackHours: Double = 0.0
    @Published var AsimHours: Double = 0.0
    @Published var AsimfrontHours: Double = 0.0
    @Published var AsimbackHours: Double = 0.0
    @Published var upcomingBirthday: Date?
    @Published var semi1Start: Date?
    @Published var semi1End: Date?
    @Published var semi2Start: Date?
    @Published var semi2End: Date?
    
    var aircraft = ["UH-60L", "UH-60M", "HH-60L", "HH-60M", "CH-47", "AH-64E", "AH-64D", "MH-60M", "MH-47G", "UH-72", "TH-67"]
    var rcmduty = ["PI", "PC", "IP", "UT", "MF", "IE", "SP", "ME", "XP"]
    var nrcmduty = ["CE", "SI", "FE", "FI", "OR"]
    
    private var userId: String
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    
    init(userId: String) {
        self.userId = userId
        fetchData(userId: userId)
    }
    
    func delete(id: String) {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        let collectionRef = db.collection("users/\(uId)/FlightLog")
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error finding document: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            for document in documents {
                var logs = document.data()["logs"] as? [[String: Any]] ?? []
                if let index = logs.firstIndex(where: { $0["id"] as? String == id }) {
                    logs.remove(at: index)
                    collectionRef.document(document.documentID).updateData(["logs": logs]) { error in
                        if let error = error {
                            print("Error deleting log: \(error.localizedDescription)")
                        } else {
                            print("Log deleted successfully.")
                        }
                    }
                }
            }
        }
    }
    
    func fetchData(userId: String) {
        let collectionRef = db.collection("users").document(userId).collection("FlightLog")
        
        // Add snapshot listener to listen for changes in the collection
        listener = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            self.items.removeAll()
            for document in querySnapshot!.documents {
                let data = document.data() // Retrieve the entire document
                
                guard let logs = data["logs"] as? [[String: Any]] else {
                    print("Error: logs field is not formatted as expected.")
                    continue
                }
                
                for logData in logs {
                    do {
                        // Decode each log entry from JSON to FlightLogItem
                        let jsonData = try JSONSerialization.data(withJSONObject: logData)
                        let flightLog = try JSONDecoder().decode(FlightLogItem.self, from: jsonData)
                        self.items.append(flightLog)
                    } catch let error {
                        print("Error decoding flight log entry: \(error.localizedDescription)")
                    }
                }
            }
            
            // Sort the items by date of flight in descending order
            self.items.sort(by: { $0.dof > $1.dof })
            print(items)
            updateValues()
        }
    }

    
    func updateValues() {
        calculateDates()
        totalHours = calculateTotalHours()
        totalngHours = calculateTotalNGHours()
        totalnsHours = calculateTotalNSHours()
        totalwxHours = calculateTotalWXHours()
        totalfrontHours = calculatetotalfrontHours()
        totalbackHours = calculatetotalbackHours()
        lastNGflight = findLastNGFlight()
        lastNSflight = findLastNSFlight()
        p1tHours = calculateP1tHours()
        p1ngHours = calculateP1ngHours()
        p1nsHours = calculateP1nsHours()
        p1hwxHours = calculateP1hwxHours()
        p1nHours = calculateP1nHours()
        p1frontHours = calculateP1frontHours()
        p1backHours = calculateP1backHours()
        p1simHours = calculateP1simHours()
        p1simfrontHours = calculateP1simfrontHours()
        p1simbackHours = calculateP1simbackHours()
        p1simhwxHours = calculateP1simhwxHours()
        p2tHours = calculateP2tHours()
        p2ngHours = calculateP2ngHours()
        p2nsHours = calculateP2nsHours()
        p2hwxHours = calculateP2hwxHours()
        p2nHours = calculateP2nHours()
        p2frontHours = calculateP2frontHours()
        p2backHours = calculateP2backHours()
        p2simHours = calculateP2simHours()
        p2simfrontHours = calculateP2simfrontHours()
        p2simbackHours = calculateP2simbackHours()
        p2simhwxHours = calculateP2simhwxHours()
        AtHours = calculateAtHours()
        AngHours = calculateAngHours()
        AnsHours = calculateAnsHours()
        AnHours = calculateAnHours()
        AfrontHours = calculateAfrontHours()
        AbackHours = calculateAbackHours()
        AhwxHours = calculateAhwxHours()
        AsimHours = calculateAsimHours()
        AsimfrontHours = calculateAsimfrontHours()
        AsimbackHours = calculateAsimbackHours()
    }
    
    private func calculateTotalHours() -> Double {
        return items.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateTotalNGHours() -> Double {
        let ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" }
        return ngItems.reduce(0.0) { $0 + $1.hours }
    }
    private func calculatetotalfrontHours() -> Double {
        let frontItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "F"}
        return frontItems.reduce(0.0) {$0 + $1.hours}
    }
    private func calculatetotalbackHours() -> Double {
        let backItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "B"}
        return backItems.reduce(0.0) {$0 + $1.hours}
    }
    private func calculateTotalWXHours() -> Double {
        let wxItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "W" }
        return wxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateTotalNSHours() -> Double {
        let nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" }
        return nsItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func findLastNGFlight() -> Date? {
        let ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" }
        guard let lastNGItem = ngItems.max(by: { $0.dof < $1.dof }) else {
            return nil
        }
        return Date(timeIntervalSince1970: lastNGItem.dof)
    }
    
    private func findLastNSFlight() -> Date? {
        let nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" }
        guard let lastNSItem = nsItems.max(by: { $0.dof < $1.dof }) else {
            return nil
        }
        return Date(timeIntervalSince1970: lastNSItem.dof)
    }
    
    private func calculateP1tHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi2End else {
            return 0.0
        }
        let filteredItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return filteredItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1ngHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1ngItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1nsHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1nsItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1nHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1nItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "N" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1nItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1frontHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1frontItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "F" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1backHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1backItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "B" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1hwxHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1hwxItems = filterItemsByAllowedAircraft(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1simItems = filterItemsBySim(items)
            .filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        
        return p1simItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simhwxHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1hwxItems = filterItemsBySim(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simfrontHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1frontItems = filterItemsBySim(items).filter { ($0.seat == "F") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simbackHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1backItems = filterItemsBySim(items).filter { ($0.seat == "B") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2tHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let filteredItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return filteredItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2ngHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2ngItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2nsHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2nsItems.reduce(0.0) { $0 + $1.hours }
    }
    private func calculateP2frontHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi2End else {
            return 0.0
        }
        let p2frontItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "F" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2backHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi2End else {
            return 0.0
        }
        let p2backItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "B" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2nHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi2End else {
            return 0.0
        }
        let p2nItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "N" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2nItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2hwxHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2hwxItems = filterItemsByAllowedAircraft(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2simItems = filterItemsBySim(items)
            .filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        
        return p2simItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simhwxHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2hwxItems = filterItemsBySim(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    private func calculateP2simfrontHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p1frontItems = filterItemsBySim(items).filter { ($0.seat == "F") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simbackHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p1backItems = filterItemsBySim(items).filter { ($0.seat == "B") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    private func calculateAtHours() -> Double {
        return p1tHours + p2tHours
    }
    
    private func calculateAngHours() -> Double {
        return p1ngHours + p2ngHours
    }
    
    private func calculateAnsHours() -> Double {
        return p1nsHours + p2nsHours
    }
    
    private func calculateAnHours() -> Double {
        return p1nHours + p2nHours
    }
    private func calculateAfrontHours() -> Double{
        return p1frontHours + p2frontHours
    }
    private func calculateAbackHours() -> Double{
        return p2backHours + p2backHours
    }
    private func calculateAhwxHours() -> Double {
        return p1hwxHours + p2hwxHours
    }
    private func calculateAsimHours() -> Double {
            return p1simHours + p2simHours
        }
    private func calculateAsimfrontHours() -> Double {
            return p1simfrontHours + p2simfrontHours
    }
    private func calculateAsimbackHours() -> Double {
        return p1simbackHours + p2simbackHours
    }
    private func totalHours(inDateRange startDate: Date, endDate: Date) -> Double {
        let filteredItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return filteredItems.reduce(0.0) { $0 + $1.hours }
    }
    
    func calculateDates() {
        guard let birthday = SettingsManager.shared.birthday else {
            print("No birthday set in SettingsManager")
            self.upcomingBirthday = nil
            self.semi1Start = nil
            self.semi1End = nil
            self.semi2Start = nil
            self.semi2End = nil
            return
        }

        var calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/New_York") ?? TimeZone.current
        calendar.timeZone = timeZone

        // Calculate the next birthday date based on today's date
        let today = Date()
        guard var nextBirthday = calendar.date(from: DateComponents(year: calendar.component(.year, from: today), month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) else {
            print("Failed to compute next birthday")
            return
        }

        if nextBirthday < today {
            nextBirthday = calendar.date(byAdding: .year, value: 1, to: nextBirthday)!
        }

        print("Next birthday: \(nextBirthday)")

        // Add one month to the next birthday and set the day to 1
        var components = DateComponents()
        components.month = 1
        components.day = -calendar.component(.day, from: nextBirthday) + 1

        guard let firstDayOfFollowingMonth = calendar.date(byAdding: components, to: nextBirthday) else {
            print("Failed to compute first day of the following month")
            return
        }

        print("First day of the month following the next birthday: \(firstDayOfFollowingMonth)")

        guard let lastDayOfBirthdayMonth = calendar.date(byAdding: DateComponents(day: -1), to: firstDayOfFollowingMonth) else {
            print("Failed to compute last day of the birthday month")
            return
        }

        print("Last day of the month following the next birthday: \(lastDayOfBirthdayMonth)")

        self.semi2End = lastDayOfBirthdayMonth
        print("Semi2 End Date: \(self.semi2End!)")

        // Subtract five months from semi2End and set the day to the 1st
        components = DateComponents()
        components.month = -5
        guard let startOfFiveMonthsPrior = calendar.date(byAdding: components, to: self.semi2End!) else {
            print("Failed to compute start of five months prior")
            return
        }

        guard let firstDayOfFiveMonthsPrior = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfFiveMonthsPrior)) else {
            print("Failed to set day to 1 of five months prior")
            return
        }

        self.semi2Start = firstDayOfFiveMonthsPrior
        print("Semi2 Start Date: \(self.semi2Start!)")

        // Subtract one day from semi2Start to set semi1End
        guard let semi1EndDate = calendar.date(byAdding: .day, value: -1, to: self.semi2Start!) else {
            print("Failed to compute semi1End")
            return
        }
        self.semi1End = semi1EndDate
        print("Semi1 End Date: \(self.semi1End!)")

        // Subtract five months from semi1End and set the day to 1
        components.month = -5
        components.day = 1 - calendar.component(.day, from: semi1EndDate)
        guard let semi1StartDate = calendar.date(byAdding: components, to: semi1EndDate) else {
            print("Failed to compute semi1Start")
            return
        }

        self.semi1Start = semi1StartDate
        print("Semi1 Start Date: \(self.semi1Start!)")
    }
    
    private func filterItemsByAllowedAircraft(_ items: [FlightLogItem]) -> [FlightLogItem] {
        let filteredItems = items.filter { aircraft.contains($0.acft) }
        print("Items filtered by allowed aircraft:")
        print(filteredItems)
        return filteredItems
    }

    private func filterItemsBySim(_ items: [FlightLogItem]) -> [FlightLogItem] {
        let filteredItems = items.filter { !aircraft.contains($0.acft) }
        print("Items filtered by simulation:")
        print(filteredItems)
        return filteredItems
    }
}
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class LogFlightViewModel: ObservableObject {
    @Published var logflightacft: String = String(describing: SettingsManager.shared.aircraft ?? "UH-60M")
    @Published var logdate = Date()
    @Published var logflightduty: String = "PI"
    @Published var logflightcondition: String = "D"
    @Published var logseatposition: String = "F"
    @Published var logflighthrs: Double = 0.0
    @Published var showAlert = false

    init() {}

    var formattedHours: String {
        return String(format: "%.1f", logflighthrs)
    }

    func save() {
        guard canSave else {
            return
        }
        
        // Get current user id
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Prepare the new log entry as a dictionary
        let newLogEntry = FlightLogItem(
            id: UUID().uuidString,
            dof: self.logdate.timeIntervalSince1970,
            acft: self.logflightacft,
            duty: self.logflightduty,
            condition: self.logflightcondition,
            seat: self.logseatposition,
            hours: self.logflighthrs,
            createdDate: Date().timeIntervalSince1970
        ).asDictionary()

        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        // Check if there is a document with space for logs
        collectionRef.whereField("entryCount", isLessThan: 1500).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            if let document = querySnapshot?.documents.first {
                let documentRef = document.reference
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let documentSnapshot: DocumentSnapshot
                    do {
                        documentSnapshot = try transaction.getDocument(documentRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    var logs = documentSnapshot.data()?["logs"] as? [[String: Any]] ?? []
                    logs.append(newLogEntry)
                    let newEntryCount = logs.count
                    
                    transaction.updateData(["logs": logs, "entryCount": newEntryCount], forDocument: documentRef)
                    return nil
                }) { _, error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Log added to existing document.")
                    }
                }
            } else {
                // No document found, need to create a new one
                let newDocumentRef = collectionRef.document()
                let initialData = ["logs": [newLogEntry], "entryCount": 1] as [String : Any]
                newDocumentRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating new document: \(error.localizedDescription)")
                    } else {
                        print("New document created with first log.")
                    }
                }
            }
        }
    }


    var canSave: Bool {
        // Check if logdate is on or before today
        guard logdate <= Date() else {
            return false
        }
        
        // Check if logflighthrs is greater than 0
        guard logflighthrs > 0 else {
            return false
        }
        
        // Check if required fields are not empty
        guard !logflightacft.isEmpty, !logflightduty.isEmpty, !logflightcondition.isEmpty else {
            return false
        }
        
        return true
    }
}
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
import UIKit
import FirebaseAuth
import FirebaseFirestore
import MobileCoreServices // Required for file types

class ImportLogListViewModel: NSObject, ObservableObject {
    @Published var isDocumentPickerPresented = false
    @Published var importLogItems: [ImportLogItem] = []

    func parseCSV(fileURL: URL) throws -> [ImportLogItem] {
        var items = [ImportLogItem]()
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = contents.components(separatedBy: "\n")
        var isFirstLine = true
        
        for row in rows {
            if isFirstLine {
                isFirstLine = false
                continue
            }
            
            let columns = row.split(separator: ",").map { String($0) }
            if columns.count == 7 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                
                let item = ImportLogItem(
                    id: UUID().uuidString,
                    dof: dateFormatter.date(from: columns[1])?.timeIntervalSince1970 ?? 0,
                    acft: columns[0],
                    duty: columns[2],
                    condition: columns[3],
                    seat: columns[4],
                    hours: Double(columns[5]) ?? 0,
                    createdDate: Date().timeIntervalSince1970
                )
                items.append(item)
            }
        }
        return items.sorted(by: { $0.dof < $1.dof })
    }
    
    func pickCSVFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func saveImportLogItems() {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        let logsCollectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        logsCollectionRef.whereField("entryCount", isLessThan: 1500).limit(to: 1).getDocuments { [self] snapshot, error in
            if let error = error {
                print("Error retrieving documents: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot?.documents.first {
                let documentRef = document.reference
                
                var entryCount = 0
                var currentLogs = document.data()["logs"] as? [[String: Any]] ?? []
                entryCount = document.data()["entryCount"] as? Int ?? 0
                
                for item in self.importLogItems {
                    if entryCount < 1500 {
                        let newLog = [
                            "id": UUID().uuidString, // Generate a unique ID for each log item
                            "dof": item.dof,
                            "acft": item.acft,
                            "duty": item.duty,
                            "condition": item.condition,
                            "seat": item.seat,
                            "hours": item.hours,
                            "createdDate": item.createdDate
                        ] as [String : Any]
                        
                        currentLogs.append(newLog)
                        entryCount += 1
                    }
                }
                
                documentRef.updateData([
                    "logs": currentLogs,
                    "entryCount": entryCount
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Logs added to existing document.")
                    }
                }
            } else {
                let newDocumentRef = logsCollectionRef.document()
                var logs = [[String: Any]]()
                
                for item in importLogItems {
                    let newLog = [
                        "id": UUID().uuidString, // Generate a unique ID for each log item
                        "dof": item.dof,
                        "acft": item.acft,
                        "duty": item.duty,
                        "condition": item.condition,
                        "seat": item.seat,
                        "hours": item.hours,
                        "createdDate": item.createdDate
                    ] as [String : Any]
                    
                    logs.append(newLog)
                }
                
                let initialData = [
                    "logs": logs,
                    "entryCount": self.importLogItems.count
                ] as [String : Any]
                
                newDocumentRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating new document: \(error.localizedDescription)")
                    } else {
                        print("New document created with logs.")
                    }
                }
            }
        }
    }



}

extension ImportLogListViewModel: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }

        if fileURL.startAccessingSecurityScopedResource() {
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }

            do {
                importLogItems = try parseCSV(fileURL: fileURL)
                print("CSV file imported successfully.")
            } catch {
                print("Error importing CSV file: \(error.localizedDescription)")
            }
        } else {
            print("Error: Failed to start accessing security-scoped resource.")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
import Foundation
import SwiftUI
import RevenueCat

class UserViewModel: ObservableObject {
    @Published var isSubscriptionActive = false

    init() {
        fetchSubscriptionStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubscriptionStatusChange), name: .subscriptionStatusDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .subscriptionStatusDidChange, object: nil)
    }

    @objc private func handleSubscriptionStatusChange(notification: Notification) {
        if let customerInfo = notification.object as? CustomerInfo {
            self.isSubscriptionActive = customerInfo.entitlements.all["All Access"]?.isActive == true
        }
    }

    func fetchSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
                // Handle error, potentially use cached info
                if let cachedCustomerInfo = Purchases.shared.cachedCustomerInfo {
                    self.isSubscriptionActive = cachedCustomerInfo.entitlements.all["All Access"]?.isActive == true
                }
                return
            }
            self.isSubscriptionActive = customerInfo?.entitlements.all["All Access"]?.isActive == true
        }
    }
}
import SwiftUI
import RevenueCatUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        Group {
            if userViewModel.isSubscriptionActive {
                if viewModel.isSignedIn && !viewModel.currentUserId.isEmpty {
                    accountView
                } else {
                    LoginView()
                }
            } else {
                PaywallView()
            }
        }
        .onReceive(userViewModel.$isSubscriptionActive) { newValue in
            print("Subscription status changed: \(newValue)")
            // Additional logic if needed when subscription status changes
        }
        .onAppear {
            // Ensure userViewModel fetches the subscription status when the view appears
            userViewModel.fetchSubscriptionStatus()
        }
    }

    @ViewBuilder
    var accountView: some View {
        TabView {
            StartPageView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            LogbookView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Logbook", systemImage: "book")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel()) // Provide a UserViewModel for previews
    }
}
import SwiftUI

struct LoginView: View {
    @StateObject var viewmodel = LoginViewModel()
    var body: some View {
        NavigationStack {
        VStack {
                //HEADER
                Headerview(title: "ACES LOGBOOK", 
                           subtitle: "You Boys Like Mexico?",
                           angle: -100,
                           backgroundcolor: .red)
                .offset(y: -155)
                //LOGIN FORMS
            Form {
                if !viewmodel.errorMessage.isEmpty{
                    Text(viewmodel.errorMessage)
                        .foregroundColor(.red)
                }
                TextField("Email Address", text: $viewmodel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                SecureField("Password", text: $viewmodel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                albutton(title: "LOGIN", bgroundcolor: .green) {
                    viewmodel.login()
                }
            }
                //navigate to forgot password page
                NavigationLink("Forgot Password", destination: ForgotPasswordView())
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)

            }.scenePadding()
            VStack {
                Text("New Here?")
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding()
                NavigationLink("Create An Account ", destination: RegisterView())
            }
        }.navigationBarBackButtonHidden(true)
    }
}
#Preview {
    LoginView()
}
import SwiftUI
struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    var body: some View {
        NavigationStack {
        VStack {
            Headerview(title: "ACES LOG", subtitle: "Signup Here", angle: 100, backgroundcolor: .blue)
                .offset(y: -150)
            Form {
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                albutton(title: "CREATE ACCOUNT", bgroundcolor: .green) {//action
                    viewModel.register()
                }
            }
        }
            VStack {
                Text("Not New Here?")
                    .font(.system(size: 30))
                    .padding()
                NavigationLink("Login", destination: LoginView())
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
        }.navigationBarBackButtonHidden(true)
    }
}
//CREATE ACCOUNT")
#Preview {
RegisterView()
}
import SwiftUI

struct StartPageView: View {
    // Initialize Firestorequery directly in StartPageView
    @StateObject var firestoreQuery: Firestorequery

    init(userId: String) {
        _firestoreQuery = StateObject(wrappedValue: Firestorequery(userId: userId))
    }
    // DateFormatter to format the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("ACES FLIGHT LOG")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
            }.padding(.top)
            ScrollView {
                Text ("TOTALS")
                    .font(.title)
                VStack {
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.totalHours))")
                    
                    Text("Total NG Hours: \(String(format: "%.1f", firestoreQuery.totalngHours))")
                    
                    Text("Total WX Hours: \(String (format: "%.1f", firestoreQuery.totalwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total NS Hours: \(String(format: "%.1f", firestoreQuery.totalnsHours))")
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total Front Seat Hours: \(String(format: "%.1f", firestoreQuery.totalfrontHours))")
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total Back Seat Hours: \(String(format: "%.1f", firestoreQuery.totalbackHours))")
                    }
                }
                // Convert lastNGflight to a string for display
                if let lastNGFlight = firestoreQuery.lastNGflight {
                    let daysSinceLastNGFlight = Calendar.current.dateComponents([.day], from: lastNGFlight, to: Date()).day ?? 0
                    //Change text to red if >60 days
                    let textColor: Color = daysSinceLastNGFlight > 60 ? .red : .primary
                    Text("Last NG Flight: \(dateFormatter.string(from: lastNGFlight))")
                        .foregroundColor(textColor)
                }
                
                // Conver lastNSflight to a string for display
                if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D" {
                    if let lastNSFlight = firestoreQuery.lastNSflight {
                        let daysSinceLastNSFlight = Calendar.current.dateComponents([.day], from: lastNSFlight, to: Date()).day ?? 0
                        let textColor: Color = daysSinceLastNSFlight > 60 ? .red : .primary
                        Text("Last NS Flight \(dateFormatter.string(from: lastNSFlight))")
                            .foregroundColor(textColor)
                    }
                }
                VStack{
                    Text("SEMIANNUAL")
                        .font(.title)
                    HStack {
                        if let semi1StartDate = firestoreQuery.semi1Start {
                            Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                        } else {
                            Text("Start: Not available")
                        }
                        if let semi1EndDate = firestoreQuery.semi1End {
                            Text("End: \(dateFormatter.string(from: semi1EndDate))")
                        } else {
                            Text("End: Not available")
                        }
                    }
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p1tHours))")
                        .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p1tHours)  ? .red : .primary)
                    
                    Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1hwxHours))")
                        .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p1hwxHours)  ? .red : .primary)
                    
                    Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p1nHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                    
                    Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p1ngHours))")
                        .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p1ngHours)  ? .red : .primary)
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p1nsHours))")
                            .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p1nsHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1frontHours))")
                            .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p1frontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1backHours))")
                            .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p1backHours)  ? .red : .primary)
                    }
                    
                    Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p1simHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                    
                    Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1simhwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simfrontHours))")
                            .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p1simfrontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simbackHours))")
                            .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p1simbackHours)  ? .red : .primary)
                    }
                }.padding()
                    
                VStack{
                    Text("SEMIANNUAL")
                        .font(.title)
                    HStack {
                        if let semi2StartDate = firestoreQuery.semi2Start {
                            Text("Start: \(dateFormatter.string(from: semi2StartDate))")
                        } else {
                            Text("Start: Not available")
                        }
                        
                        if let semi2EndDate = firestoreQuery.semi2End {
                            Text("End: \(dateFormatter.string(from: semi2EndDate))")
                        } else {
                            Text("End: Not available")
                        }
                    }
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p2tHours))")
                        .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p2tHours)  ? .red : .primary)
                    
                    Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2hwxHours))")
                        .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p2hwxHours) ? .red : .primary)
                    
                    Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p2nHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p2nHours)  ? .red : .primary)
                    
                    Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p2ngHours))")
                        .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p2ngHours)  ? .red : .primary)
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p2nsHours))")
                            .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p2nsHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p2frontHours))")
                            .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p2frontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p2backHours))")
                            .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p2backHours)  ? .red : .primary)
                    }
            
                    Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p2simHours))")
                    
                    Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2simhwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Seat Front Hours: \(String(format: "%.1f", firestoreQuery.p2simfrontHours))")
                            .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p2simfrontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Seat Back Hours: \(String(format: "%.1f", firestoreQuery.p2simbackHours))")
                            .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p2simbackHours)  ? .red : .primary)
                    }
                }
                    VStack{
                        Text("ANNUAL PERIOD ")
                            .font(.title)
                        HStack {
                            if let semi1StartDate = firestoreQuery.semi1Start {
                                Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                            } else {
                                Text("Start: Not available")
                            }
                            
                            if let semi2EndDate = firestoreQuery.semi2End {
                                Text("End: \(dateFormatter.string(from: semi2EndDate))")
                            } else {
                                Text("End: Not available")
                            }
                        }
                        
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.AtHours))")
                            .foregroundColor(SettingsManager.shared.semithrs * 2 > Int(firestoreQuery.AtHours) ? .red : .primary)
                        Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.AhwxHours))")
                            .foregroundColor(SettingsManager.shared.semihwxhrs * 2 > Int(firestoreQuery.AhwxHours) ? .red : .primary)
                        
                        Text("Night Hours: \(String(format: "%.1f", firestoreQuery.AnHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs * 2 > Int(firestoreQuery.AnHours) ? .red : .primary)
                        
                        Text("NG Hours: \(String(format: "%.1f", firestoreQuery.AngHours))")
                            .foregroundColor(SettingsManager.shared.seminghrs * 2 > Int(firestoreQuery.AngHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("NS Hours: \(String(format: "%.1f", firestoreQuery.AnsHours))")
                                .foregroundColor(SettingsManager.shared.seminshrs * 2 > Int(firestoreQuery.AnsHours) ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.AfrontHours))")
                                .foregroundColor(SettingsManager.shared.semifronthrs * 2 > Int(firestoreQuery.AfrontHours) ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.AbackHours))")
                                .foregroundColor(SettingsManager.shared.semibackhrs * 2 > Int(firestoreQuery.AbackHours) ? .red : .primary)
                        }
                        
                        Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.AsimHours))")
                            .foregroundColor(SettingsManager.shared.asimhrs > Int(firestoreQuery.AsimHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Front Hours: \(String(format: "%.1f", firestoreQuery.AsimfrontHours))")
                                .foregroundColor(SettingsManager.shared.asimfronthrs > Int(firestoreQuery.AsimfrontHours)  ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Back Hours: \(String(format: "%.1f", firestoreQuery.AsimbackHours))")
                                .foregroundColor(SettingsManager.shared.asimbackhrs > Int(firestoreQuery.AsimbackHours)  ? .red : .primary)
                        }
                        
                    }.padding()
                }
            }
            .onAppear {
                // run update of values when view appears
                firestoreQuery.updateValues()
            }
        }
    }
    struct StartPageView_Previews: PreviewProvider {
        static var previews: some View {
            StartPageView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
import SwiftUI

struct LogbookView: View {
    @ObservedObject var firestoreQuery: Firestorequery
    @State private var showingFlightLogView = false
    @State private var showingImportLogBookView = false
    
    init(userId: String) {
        self.firestoreQuery = Firestorequery(userId: userId)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("LOGBOOK")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                
                List(firestoreQuery.items) { item in
                    LogBookItemView(flightlogitemview: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                // Removed reference to unused index
                                firestoreQuery.delete(id: item.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
                .listStyle(PlainListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFlightLogView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(
                        destination: ImportLogListView(),
                        label: {
                            Text("Import -12")
                        })
                }
            }
            .sheet(isPresented: $showingFlightLogView) {
                LogFlightView(viewmodel: LogFlightViewModel())
            }
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
import SwiftUI

struct ImportLogListView: View {
    @StateObject private var viewModel = ImportLogListViewModel()
    @State private var itemsToDelete = Set<Int>()
    @State private var showFormatInstructions = true // State variable to control HStack visibility
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            if showFormatInstructions {
                Text("Please make sure your CSV follows this format")
                HStack {
                    VStack {
                        Text("A")
                        Text("Acft")
                    }
                    VStack {
                        Text("B")
                        Text("Date")
                    }
                    VStack {
                        Text("C")
                        Text("Duty")
                    }
                    VStack {
                        Text("D")
                        Text("Condition")
                    }
                    VStack {
                        Text("E")
                        Text("Seat")
                    }
                    VStack {
                        Text("F")
                        Text("Hours")
                    }
                }
            }
            VStack {
                List {
                    ForEach(viewModel.importLogItems.indices, id: \.self) { index in
                        ImportLogItemView(importLogItem: viewModel.importLogItems[index])
                    }
                    .onDelete(perform: deleteItems)
                }
                
                Button(action: {
                    viewModel.saveImportLogItems()
                    self.presentationMode.wrappedValue.dismiss() // Navigate back to the main view
                }) {
                    Text("SAVE LOGBOOK")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarItems(
                trailing: Button(action: {
                    viewModel.pickCSVFile()
                    showFormatInstructions = false // Hide the HStack when import button is pressed
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
            )
            .navigationTitle("Import Log List")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        // Implement item deletion logic here
    }
}

struct ImportLogListView_Previews: PreviewProvider {
    static var previews: some View {
        ImportLogListView()
    }
}
import SwiftUI

struct ImportLogItemView: View {
    let importLogItem: ImportLogItem
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Text("Date")
                    .font(.caption)
                Text("\(formattedDate(from: importLogItem.dof))")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("ACFT")
                    .font(.caption)
                Text("\(importLogItem.acft)")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("DUTY")
                    .font(.caption)
                Text("\(importLogItem.duty)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("COND")
                    .font(.caption)
                Text("\(importLogItem.condition)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            if importLogItem.acft == "AH-64" || importLogItem.acft == "AH-64E" {
                VStack {
                    Text("SEAT")
                        .font(.caption)
                    Text("\(importLogItem.seat)")
                        .font(.headline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }

            VStack {
                Text("HRS")
                    .font(.caption)
                Text("\(String(format: "%.1f", importLogItem.hours))")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Format to display only day, month, and year
        return formatter.string(from: date)
    }
}
import SwiftUI

struct LogBookItemView: View {
    let flightlogitemview: FlightLogItem
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Text("Date")
                    .font(.caption)
                Text("\(formattedDate(from: flightlogitemview.dof))")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("ACFT")
                    .font(.caption)
                Text("\(flightlogitemview.acft)")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("DUTY")
                    .font(.caption)
                Text("\(flightlogitemview.duty)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("COND")
                    .font(.caption)
                Text("\(flightlogitemview.condition)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            if flightlogitemview.acft == "AH-64D" || flightlogitemview.acft == "AH-64E" {
                VStack {
                    Text("SEAT")
                        .font(.caption)
                    Text("\(flightlogitemview.seat)")
                        .font(.headline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }

            VStack {
                Text("HRS")
                    .font(.caption)
                Text("\(String(format: "%.1f", flightlogitemview.hours))")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct LogBookItemView_Previews: PreviewProvider {
    static var previews: some View {
        LogBookItemView(flightlogitemview: FlightLogItem(id: "hello", dof: Date().timeIntervalSince1970, acft: "UH-60L", duty: "PI", condition: "N", seat: "F", hours: 1.2, createdDate: Date().timeIntervalSince1970))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
import SwiftUI

struct LogFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewmodel = LogFlightViewModel()
    var aircraft = ["UH-60L", "UH-60M", "HH-60L", "HH-60M", "CH-47", "AH-64E", "AH-64D", "MH-60M", "MH-47G", "UH-72A", "TH-67", "SIM"]
    var rcmduty = ["PI", "PC", "IP", "UT", "MF", "IE", "SP", "ME", "XP"]
    var nrcmduty = ["CE", "SI", "FE", "FI", "OR"]
    var condition = ["D", "N", "NG", "NS", "H", "W"]
    var seatAH = ["F", "B"]
    var seat = ["L", "R"]
    @State private var defaultAircraft: String = ""

    var body: some View {
        VStack {
            Text("LOG FLIGHT")
                .font(.system(size: 40))
                .bold()
                .padding()
            
            Text("Date of Flight")
                .font(.system(size: 30))
            DatePicker("Select a date", selection: $viewmodel.logdate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .font(.system(size: 30))
            
            Text("Aircraft")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightacft, label: Text("Aircraft")) {
                ForEach(aircraft, id: \.self) { selacft in
                    Text(selacft)
                        .tag(selacft)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
                if let defaultAircraft = SettingsManager.shared.aircraft {
                    // Use the unwrapped value as the default selection
                    self.viewmodel.logflightacft = defaultAircraft
                } else {
                    // Default to the first item in the aircraft array
                    self.viewmodel.logflightacft = aircraft.first ?? ""
                }
            }
            
            Text("Duty")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightduty, label: Text("Duty")) {
                ForEach(dutyOptions, id: \.self) { duty in
                    Text(duty)
                        .tag(duty)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Text("Condition")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightcondition, label: Text("Condition")) {
                ForEach(condition, id: \.self) { conditionItem in
                    Text(conditionItem)
                        .tag(conditionItem)
                }
            }
            
            if viewmodel.logflightacft == "AH-64E" || viewmodel.logflightacft == "AH-64D" {
                Text("Seat")
                    .font(.system(size: 30))
                Picker(selection: $viewmodel.logseatposition, label: Text("Seat")) {
                    ForEach(seatAH, id: \.self) { status in
                        Text(status)
                            .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            
            Text("Time")
                .font(.system(size: 30))
            TextField("Enter hours (e.g., ##.#)", text: Binding(
                get: {
                    // Format the Double value as a String with one decimal place
                    String(format: "%.1f", viewmodel.logflighthrs)
                },
                set: { newValue in
                    // Attempt to convert the input String back to a Double
                    if let number = Double(newValue) {
                        // Update the view model's logflighthrs property
                        viewmodel.logflighthrs = number
                    }
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .frame(width: 150)
            .padding(.bottom, 20)
            
            Button(action: {
                if viewmodel.canSave {
                    presentationMode.wrappedValue.dismiss()
                    viewmodel.save()
                } else {
                    viewmodel.showAlert = true
                }
            }) {
                Text("SAVE")
                    .font(.system(size: 30))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
        }
        .onAppear{
            viewmodel.logflightduty = dutyOptions.first ?? ""
            viewmodel.logflightcondition = condition.first ?? ""
            viewmodel.logseatposition = seatAH.first ?? ""
        }
        .alert(isPresented: $viewmodel.showAlert) {
            Alert(
                title: Text("ERROR"),
                message: Text("Please Fill In All Fields and Select Date Today or Earlier"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    var dutyOptions: [String] {
        let cmStatus = SettingsManager.shared.cmstatus
        switch cmStatus {
        case "RCM":
            return rcmduty
        case "NRCM":
            return nrcmduty
        default:
            return rcmduty // Default to rcmduty if cmstatus is not recognized
        }
    }
}

#Preview {
    LogFlightView()
}
import SwiftUI
import UIKit 

struct SettingsView: View {
    @StateObject var viewmodel = SettingsViewModel()
    @StateObject var firestoreQuery = Firestorequery(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    @State private var displayedBirthday: String = ""
    @State private var displayedCMStatus: String = ""
    @State private var displayedAircraft: String = ""
    @State private var displayedAthrs: String = ""
    @State private var displayedAnhrs: String = ""
    @State private var displayedAnghrs: String = ""
    @State private var displayedAnshrs: String = ""
    @State private var displayedAhwxhrs: String = ""
    @State private var displayedFronthrs: String = ""
    @State private var displayedBackhrs: String = "" 
    @State private var displayedsimhrs: String = ""
    @State private var displayedsimseatFhrs: String = ""
    @State private var displayedsimseatBhrs: String = ""
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var aircraft = ["UH-60L", "UH-60M", "HH-60L", "HH-60M", "CH-47", "AH-64E", "AH-64D", "MH-60M", "MH-47G", "UH-72A"]
    var cmstatus = ["RCM", "NRCM"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("SETTINGS")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                
                ScrollView {
                    HStack {
                        // Display user settings using @State properties
                        Text(displayedBirthday)
                            .padding()
                        Text(displayedCMStatus)
                            .padding()
                        Text(displayedAircraft)
                            .padding()
                    }
                    .offset(y: -10)
                    Text("Required Hours")
                        .font(.system(size: 30))
                    HStack {
                        Text("Total: \(displayedAthrs)")
                        Text("NVG: \(displayedAnghrs)")
                        if SettingsManager.shared.aircraft == "AH-64E" ||  SettingsManager.shared.aircraft == "AH-64D" {
                            Text("NS: \(displayedAnshrs)")
                        }
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack{
                            Text("Front: \(displayedFronthrs)")
                            Text("Back: \(displayedBackhrs)")
                        }
                    }
                    HStack {
                        Text("N: \(displayedAnhrs)")
                        Text("H/WX: \(displayedAhwxhrs)")
                        Text("Sim: \(displayedsimhrs)")
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack {
                            Text("Front Sim: \(displayedsimseatFhrs)")
                            Text("Back Sim: \(displayedsimseatBhrs)")
                        }
                    }
                    Text("Birthday")
                        .font(.system(size: 30))
                        .scenePadding()
                    DatePicker("Select a date", selection: $viewmodel.bday, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    Text("Rated/NonRated")
                        .font(.system(size: 30))
                    if #available(iOS 17.0, *) {
                        Picker(selection: $viewmodel.cmstatus, label: Text("CM STATUS")) {
                            ForEach(cmstatus, id: \.self) { status in
                                Text(status)
                            }
                        }.pickerStyle(.palette)
                            .padding(.horizontal)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Text("AIRCRAFT")
                        .font(.system(size: 30))
                    Picker(selection: $viewmodel.acft, label: Text("Aircraft")) {
                        ForEach(aircraft, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    Text("SemiAnnual Requirements")
                        .font(.system(size: 30))
                    HStack {
                        VStack {
                            Text("Total")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.semithrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                        
                        VStack {
                            Text("Night")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.seminhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                        
                        VStack {
                            Text("NVG")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.seminghrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                    }
                    
                    HStack {
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            VStack {
                                Text("NS")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.seminshrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)}
                        VStack {
                            Text("H/WX")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.semihwxhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack {
                            VStack {
                                Text("Front")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semifronthrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                            
                            VStack {
                                Text("Back")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semibackhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                                
                            }.padding(.horizontal)
                        }
                    }
                    Text("SIM Requirements")
                        .font(.system(size: 30))
                    HStack{
                        VStack {
                            Text("TOTAL SIM")
                            TextField("0", text: $viewmodel.asimhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            VStack {
                                Text("Front SIM")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.asimfronthrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }
                            VStack {
                                Text("Back SIM")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.asimbackhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }
                        }
                    }
                    .scenePadding()
                    albutton(title: "UPDATE", bgroundcolor: .red, action: {
                        // Update SettingsManager with new values from viewmodel
                        SettingsManager.shared.birthday = viewmodel.bday
                        SettingsManager.shared.cmstatus = viewmodel.cmstatus
                        SettingsManager.shared.aircraft = viewmodel.acft
                        SettingsManager.shared.semithrs = Int(viewmodel.semithrsmin) ?? 0
                        SettingsManager.shared.seminhrs = Int(viewmodel.seminhrsmin) ?? 0
                        SettingsManager.shared.seminghrs = Int(viewmodel.seminghrsmin) ?? 0
                        SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                        SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                        SettingsManager.shared.semifronthrs = Int(viewmodel.semifronthrsmin) ?? 0
                        SettingsManager.shared.semibackhrs = Int(viewmodel.semibackhrsmin) ?? 0
                        SettingsManager.shared.semihwxhrs = Int(viewmodel.semihwxhrsmin) ?? 0
                        SettingsManager.shared.asimhrs = Int(viewmodel.asimhrsmin) ?? 0
                        firestoreQuery.updateValues()
                        SettingsManager.shared.asimfronthrs = Int(viewmodel.asimfronthrsmin) ?? 0
                        firestoreQuery.updateValues()
                        SettingsManager.shared.asimbackhrs = Int(viewmodel.asimbackhrsmin) ?? 0
                        firestoreQuery.updateValues()
                        // Update displayed settings
                        updateDisplayedSettings()
                        // Dismiss keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .font(.system(size: 30))
                    .offset(y: -20)
                    .padding(.horizontal)
                    .padding(.vertical)
                }
            }
            .onAppear {
                // Initialize displayed settings on view load
                updateDisplayedSettings()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("LOGOUT")
                            .font(.callout)
                            .padding()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteAccountAlert = true
                    }) {
                        Text("Delete Account")
                            .font(.callout)
                            .padding()
                    }
                }
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Confirm Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        // Action to logout the user
                        viewmodel.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingDeleteAccountAlert) {
                Alert(
                    title: Text("Confirm Account Deletion"),
                    message: Text("Are you sure you want to delete your account?"),
                    primaryButton: .destructive(Text("Delete")) {
                        // Action to delete the user account
                        viewmodel.deleteAccount { result in
                            switch result {
                            case .success():
                                // Handle successful account deletion
                                print("Account successfully deleted.")
                            case .failure(let error):
                                // Handle error during account deletion
                                print("Error deleting account: \(error.localizedDescription)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    // update displayed settings
    private func updateDisplayedSettings() {
        displayedBirthday = formattedDate(SettingsManager.shared.birthday)
        displayedCMStatus = SettingsManager.shared.cmstatus ?? ""
        displayedAircraft = SettingsManager.shared.aircraft ?? ""
        displayedAthrs = String(SettingsManager.shared.semithrs)
        displayedAnhrs = String(SettingsManager.shared.seminhrs)
        displayedAnghrs = String(SettingsManager.shared.seminghrs)
        displayedAnshrs = String(SettingsManager.shared.seminshrs)
        displayedFronthrs = String(SettingsManager.shared.semifronthrs)
        displayedBackhrs = String(SettingsManager.shared.semibackhrs)
        displayedAhwxhrs = String(SettingsManager.shared.semihwxhrs)
        displayedsimhrs = String(SettingsManager.shared.asimhrs)
        displayedsimseatFhrs = String(SettingsManager.shared.asimfronthrs)
        displayedsimseatBhrs = String(SettingsManager.shared.asimbackhrs)
    }
    
    //format Date into String
    private func formattedDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
import SwiftUI

struct Headerview: View {
    let title: String
    let subtitle: String
    let angle: Double
    let backgroundcolor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(backgroundcolor)
                    .frame(height: geometry.size.height * 1.5) // Expand beyond screen height
                    .rotationEffect(.degrees(angle))
                
                VStack {
                    Text(title)
                        .font(.system(size: geometry.size.width * 0.15)) // Scale font size based on width
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: geometry.size.width * 0.08)) // Scale font size based on width
                        .foregroundColor(.black)

                }
            }
            .frame(width: geometry.size.width) // Match parent width
        }
    }
}

struct Headerview_Previews: PreviewProvider {
    static var previews: some View {
        Headerview(title: "ACES LOG",
                   subtitle: "YOU BOYS LIKE MEXICO",
                   angle: 100,
                   backgroundcolor: .red)
    }
}
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // HEADER
                Headerview(title: "Forgot Password?",
                           subtitle: "We will Email you a Link to Reset",
                           angle: -100,
                           backgroundcolor: .red)
                    .offset(y: -155)
                
                // LOGIN FORMS
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)

                    albutton(title: "Reset Password", bgroundcolor: .green) {
                        viewModel.forgotPassword()
                        showAlert = true // Show alert when password reset is requested
                    }
                    .disabled(viewModel.email.isEmpty) // Disable button if email is empty
                }
                .padding()
                
                // Navigation Link to go back to Login
                NavigationLink(destination: LoginView()) {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset Email Sent"),
                      message: Text("An email has been sent to \(viewModel.email) with instructions to reset your password."),
                      dismissButton: .default(Text("OK")))
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
import SwiftUI

struct albutton: View {
    
    let title: String
    let bgroundcolor: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()}
    label: {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(bgroundcolor)
            Text(title)
                .foregroundColor(.white)
                .bold()
        }
    }
    }
}
#Preview {
    albutton(title: "hello", bgroundcolor: .red) {//action
    }
}
import Foundation

struct FlightLogItem: Codable, Identifiable {
    let id: String
    let dof: TimeInterval
    let acft: String
    let duty: String
    let condition: String
    let seat: String
    let hours: Double
    let createdDate: TimeInterval
    
}

import Foundation

struct ImportLogItem: Codable, Identifiable {
    let id: String
    let dof: TimeInterval
    let acft: String
    let duty: String
    let condition: String
    let seat: String
    let hours: Double
    let createdDate: TimeInterval
    
}
import Foundation
import SwiftUI
import RevenueCat

struct User {
    var id: String
    var name: String
    var email: String
    var joined: TimeInterval

    // Convert User to a dictionary
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "joined": joined
        ]
    }
}

