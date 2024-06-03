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
