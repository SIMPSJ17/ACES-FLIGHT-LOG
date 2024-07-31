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
                self.errorMessage = "Login Failed: \(error.localizedDescription)"
                print("Error signing in: \(error.localizedDescription)")
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
