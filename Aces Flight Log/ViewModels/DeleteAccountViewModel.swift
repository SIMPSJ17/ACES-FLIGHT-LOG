import Foundation
import FirebaseAuth

class DeleteAccountViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    func logout(completion: @escaping () -> Void) {
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard validate() else { return }
        
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in"
            return
        }
        
        // Verify user's password
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            // Password verification succeeded, proceed with account deletion
            user.delete { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Logout after successful deletion
                self.logout {}
            }
        }
    }
    
    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email"
            return false
        }
        
        return true
    }
}
