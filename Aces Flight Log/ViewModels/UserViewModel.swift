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
