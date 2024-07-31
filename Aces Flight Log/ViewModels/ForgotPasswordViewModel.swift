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
