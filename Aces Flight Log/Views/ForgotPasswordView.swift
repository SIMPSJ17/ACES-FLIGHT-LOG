import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
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
        } else {
            // Fallback on earlier versions
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
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
