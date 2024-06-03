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

