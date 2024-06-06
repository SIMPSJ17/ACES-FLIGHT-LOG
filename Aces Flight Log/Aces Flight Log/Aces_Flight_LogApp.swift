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
