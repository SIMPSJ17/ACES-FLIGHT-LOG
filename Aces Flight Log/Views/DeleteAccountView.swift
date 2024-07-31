import SwiftUI

struct DeleteAccountView: View {
    @StateObject var viewModel = DeleteAccountViewModel() // Single instance of view model
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                // Trash icon
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                
                // Text content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delete Account")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Enter email and password")
                        .foregroundColor(.white)
                }
                
                // Email TextField
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                // Password SecureField
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                // HoldButtonView
                HoldButtonView(viewModel: viewModel) // Pass viewModel down
            }
            .frame(width: 350, height: 400)
            .background(RoundedRectangle(cornerRadius: 30).fill(Color.black))
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}

struct HoldButtonView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel // Use ObservedObject here
    @State private var isComplete = false
    @State private var isSuccess = false

    var body: some View {
        VStack {
            ZStack {
                // Background rectangles
                Rectangle()
                    .foregroundColor(.red.opacity(0.5))
                Rectangle()
                    .frame(maxWidth: isComplete ? .infinity : 130)
                    .foregroundStyle(isComplete ? .black : .red)
                
                // Overlay text
                Text(isSuccess ? "Account Deleted" : "Hold to Delete")
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .clipShape(RoundedRectangle(cornerRadius: 15)) // Updated for rounded corners
            .padding(.horizontal, 8)
        }
        .onLongPressGesture(minimumDuration: 2, maximumDistance: 50) { isPressing in
            if isPressing {
                withAnimation(.linear(duration: 2)) {
                    isComplete = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !isSuccess {
                        withAnimation {
                            isComplete = false
                        }
                    }
                }
            }
        } perform: {
            withAnimation {
                isSuccess = true
                viewModel.deleteAccount()
            }
        }
    }
}
