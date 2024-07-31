import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 45) {
            forgotpasswordtopview()
            
            forgotpasswordemailTF(viewModel: viewModel) // Pass the view model
            
            Button(action: {
                viewModel.forgotPassword()
                if viewModel.isResetSuccessful {
                    showAlert = true
                }
            }, label: {
                Text("Send Reset Email")
                    .foregroundStyle(.background)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.primary, in: .rect(cornerRadius: 16))
            })
            .tint(.primary)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
            Button(action: {
                dismiss()
            }, label: {
                Text("Back to SignIn")
                    .foregroundColor(.primary)
            })
        }
        .padding(.horizontal)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Password Reset Email Sent"),
                message: Text("An email has been sent to \(viewModel.email) with instructions to reset your password."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct forgotpasswordtopview: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("ACES FLIGHT LOG")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .font(.system(size: 300))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
            
            HStack {
                Image("uh60")
                    .resizable()
                    .scaledToFit()
                    .padding()
                Image("ah64")
                    .resizable()
                    .scaledToFit()
                    .padding()
                Image("ch47")
                    .resizable()
                    .scaledToFit()
                    .padding()
                Image("uh72")
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
    }
}

struct forgotpasswordemailTF: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel // Use ObservedObject
    
    @FocusState private var isActive: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                TextField("", text: $viewModel.email)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                
                Text("Email")
                    .padding(.leading)
                    .offset(y: (isActive || !viewModel.email.isEmpty) ? -35 : 0)
                    .animation(.spring, value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
