import SwiftUI
struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    var body: some View {
        NavigationStack {
        VStack {
            Headerview(title: "ACES LOG", subtitle: "Signup Here", angle: 100, backgroundcolor: .blue)
                .offset(y: -150)
            Form {
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                albutton(title: "CREATE ACCOUNT", bgroundcolor: .green) {//action
                    viewModel.register()
                }
            }
        }
            VStack {
                Text("Not New Here?")
                    .font(.system(size: 30))
                    .padding()
                NavigationLink("Login", destination: LoginView())
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
        }.navigationBarBackButtonHidden(true)
    }
}
//CREATE ACCOUNT")
#Preview {
RegisterView()
}
