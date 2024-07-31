import SwiftUI

struct RegisterView: View {
    @StateObject var viewmodel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 45) {
            registertopview()
            
            registernameTF(viewmodel: viewmodel)
            
            registeremailTF(viewmodel: viewmodel)
            
            registerpasswordTF(viewmodel: viewmodel)

            registerbutton(viewmodel: viewmodel)
            
            Button(action: {
                dismiss()
            }, label: {
                Text("Have an Account? SignIn")
                    .foregroundColor(.primary)
            })
        }
        .padding(.horizontal)
    }
}

struct registertopview: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("ACES FLIGHT LOG")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .font(.system(size: 300))  // 1
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

struct registernameTF: View {
    @ObservedObject var viewmodel: RegisterViewModel
    @FocusState private var isActive: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                TextField("", text: $viewmodel.name)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                
                Text("Name").padding(.leading)
                    .offset(y: (isActive || !viewmodel.name.isEmpty) ? -35 : 0)
                    .animation(.spring, value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
            }
        }
    }
}

struct registeremailTF: View {
    @ObservedObject var viewmodel: RegisterViewModel
    @FocusState private var isActive: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                TextField("", text: $viewmodel.email)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                
                Text("Email").padding(.leading)
                    .offset(y: (isActive || !viewmodel.email.isEmpty) ? -35 : 0)
                    .animation(.spring, value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
            }
        }
    }
}

struct registerpasswordTF: View {
    @ObservedObject var viewmodel: RegisterViewModel
    @State private var showPassword = false
    @FocusState private var isActive: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                SecureField("", text: $viewmodel.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                    .opacity(showPassword ? 0 : 1)
                
                TextField("", text: $viewmodel.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                    .opacity(showPassword ? 1 : 0)
                
                Text("Password").padding(.leading)
                    .offset(y: (isActive || !viewmodel.password.isEmpty) ? -35 : 0)
                    .animation(.spring, value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
            }
            .overlay(alignment: .trailing) {
                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                    .padding(16)
                    .contentShape(Rectangle())
                    .foregroundStyle(showPassword ? .primary : .secondary)
                    .onTapGesture {
                        showPassword.toggle()
                    }
            }
        }
    }
}

struct registerbutton: View {
    @ObservedObject var viewmodel: RegisterViewModel
    var body: some View {
        Button(action: { viewmodel.register() }, label: {
            Text("Register")
                .foregroundStyle(.background)
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.primary, in: .rect(cornerRadius: 16))
        })
        .tint(.primary)
    }
}

#Preview {
    RegisterView()
}
