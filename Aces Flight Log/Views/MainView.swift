import SwiftUI
import RevenueCatUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        Group {
            if userViewModel.isSubscriptionActive {
                if viewModel.isSignedIn && !viewModel.currentUserId.isEmpty {
                    accountView
                } else {
                    LoginView()
                }
            } else {
                PaywallView()
            }
        }
        .onReceive(userViewModel.$isSubscriptionActive) { newValue in
            print("Subscription status changed: \(newValue)")
            // Additional logic if needed when subscription status changes
        }
        .onAppear {
            // Ensure userViewModel fetches the subscription status when the view appears
            userViewModel.fetchSubscriptionStatus()
        }
    }

    @ViewBuilder
    var accountView: some View {
        TabView {
            StartPageView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            LogbookView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Logbook", systemImage: "book")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel()) // Provide a UserViewModel for previews
    }
}
