//
//  LOGINVIEW.swift
//  Aces Flight Log
//
//  Created by Jordan Simpson on 7/29/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewmodel = LoginViewModel()
    @State private var isRegisterViewPresented = false
    @State private var isForgotPasswordPresented = false
    
    var body: some View {
        VStack(spacing: 45) {
            logintopview()
            
            loginemailTF(viewmodel: viewmodel)
            
            VStack(alignment: .trailing, spacing: 10) {
                loginpasswordTF(viewmodel: viewmodel)
                HStack {
                    Button("Forgot Password") {
                        isForgotPasswordPresented = true
                    }
                    .font(.footnote)
                    .foregroundColor(.primary)
                }
            }
            VStack {
                if !viewmodel.errorMessage.isEmpty {
                    Text(viewmodel.errorMessage)
                        .foregroundColor(.red)
                }
            }
            loginbutton(viewmodel: viewmodel)
            Button(action: {
                viewmodel.email = ""
                viewmodel.password = ""
                withAnimation {
                    isRegisterViewPresented.toggle()
                }
            }, label: {
                Text("Don't have an Account? Signup")
                    .foregroundColor(.primary)
            })
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $isRegisterViewPresented) {
            RegisterView()
        }
        .fullScreenCover(isPresented: $isForgotPasswordPresented) {
            ForgotPasswordView()
        }
    }
}

struct logintopview: View {
    var body: some View {
        VStack(spacing: 0){
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

struct loginemailTF: View {
    @ObservedObject var viewmodel: LoginViewModel
    @FocusState var isActive
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                TextField("", text: $viewmodel.email)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55).focused($isActive)
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

struct loginpasswordTF: View {
    @ObservedObject var viewmodel: LoginViewModel
    @State var showPassword = false
    @FocusState var isActive
    
    var body: some View{
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .leading) {
                SecureField("", text: $viewmodel.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55).focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                    .opacity(showPassword ? 0 : 1)
                TextField("", text: $viewmodel.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55).focused($isActive)
                    .background(.gray.opacity(0.3), in: .rect(cornerRadius: 16))
                    .opacity(showPassword ? 1 : 0)
                Text("Password").padding(.leading)
                    .offset(y: (isActive || !viewmodel.password.isEmpty) ? -35 : 0)
                    .animation(.spring, value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
            }.overlay(alignment: .trailing){
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

struct loginbutton: View {
    @ObservedObject var viewmodel: LoginViewModel
    var body: some View {
        Button(action: { viewmodel.login(); print(viewmodel.email); print(viewmodel.password); print(viewmodel.errorMessage) }, label: {
            Text("Sign In").foregroundStyle(.background).font(.title2.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.primary, in: .rect(cornerRadius: 16))
        })
        .tint(.primary)
    }
}

#Preview {
    LoginView()
}
