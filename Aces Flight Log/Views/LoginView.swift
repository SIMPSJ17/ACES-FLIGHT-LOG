import SwiftUI

struct LoginView: View {
    @StateObject var viewmodel = LoginViewModel()
    @State private var isRegisterViewPresented = false
    @State private var isForgotPasswordPresented = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
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
        } else {
            VStack {
                //HEADER
                Headerview(title: "ACES LOGBOOK",
                           subtitle: "You Boys Like Mexico?",
                           angle: -100,
                           backgroundcolor: .red)
                    .offset(y: -155)
                //LOGIN FORMS
                Form {
                    if !viewmodel.errorMessage.isEmpty {
                        Text(viewmodel.errorMessage)
                            .foregroundColor(.red)
                    }
                    TextField("Email Address", text: $viewmodel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $viewmodel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    albutton(title: "LOGIN", bgroundcolor: .green) {
                        viewmodel.login()
                    }
                }
                //navigate to forgot password page
                Button("Forgot Password") {
                    isForgotPasswordPresented = true
                }
                .foregroundColor(.blue)
                // "Create An Account" button
                Button("Create An Account") {
                    isRegisterViewPresented = true
                }
                .sheet(isPresented: $isRegisterViewPresented) {
                    RegisterView()
                }
                .sheet(isPresented: $isForgotPasswordPresented) {
                    ForgotPasswordView()
                }
                .scenePadding()
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
#Preview {
    LoginView()
}
