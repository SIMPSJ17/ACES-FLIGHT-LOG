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
