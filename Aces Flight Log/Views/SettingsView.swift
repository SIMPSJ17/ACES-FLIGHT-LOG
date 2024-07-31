import SwiftUI

struct SettingsView: View {
    @StateObject var viewmodel = SettingsViewModel()
    @StateObject var pickermodel = pickerlist()
    
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccount = false

    var cmstatus = ["RCM", "NRCM"]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                    
                    Form {
                        HStack {
                            Text("Email")
                                .font(.system(size: 20))
                            Spacer()
                            Text("\(viewmodel.userEmail)")
                                .frame(alignment: .trailing)
                        }
                        
                        Section {
                            DatePicker(
                                "Birthday",
                                selection: $viewmodel.bday,
                                displayedComponents: .date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .onChange(of: viewmodel.bday) { newBday in
                                SettingsManager.shared.birthday = newBday
                            }
                            
                            Picker("CM Status", selection: $viewmodel.cmstatus) {
                                ForEach(cmstatus, id: \.self) { status in
                                    Text(status)
                                }
                            }
                            .onChange(of: viewmodel.cmstatus) { newCMStatus in
                                SettingsManager.shared.cmstatus = newCMStatus
                            }
                            
                            Picker("Aircraft", selection: $viewmodel.acft) {
                                ForEach(pickermodel.aircraft.sorted(), id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .onChange(of: viewmodel.acft) { newValue in
                                SettingsManager.shared.aircraft = newValue
                            }
                        }
                        
                        Section("Semi Annual Aircraft Hours") {
                            NavigationLink(destination: HourPickerView(label: "Total", binding: $viewmodel.semithrsmin)) {
                                HStack {
                                    Text("Total")
                                        .font(.system(size: 20))
                                    Spacer()
                                    Text(viewmodel.semithrsmin)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                            .onChange(of: viewmodel.semithrsmin) { newValue in
                                if let intValue = Int(newValue) {
                                    SettingsManager.shared.semithrs = intValue
                                }
                            }
                            
                            NavigationLink(destination: HourPickerView(label: "Night", binding: $viewmodel.seminhrsmin)) {
                                HStack {
                                    Text("Night")
                                        .font(.system(size: 20))
                                    Spacer()
                                    Text(viewmodel.seminhrsmin)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                            .onChange(of: viewmodel.seminhrsmin) { newValue in
                                if let intValue = Int(newValue) {
                                    SettingsManager.shared.seminhrs = intValue
                                }
                            }
                            
                            NavigationLink(destination: HourPickerView(label: "NVG", binding: $viewmodel.seminghrsmin)) {
                                HStack {
                                    Text("NVG")
                                        .font(.system(size: 20))
                                    Spacer()
                                    Text(viewmodel.seminghrsmin)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                            .onChange(of: viewmodel.seminghrsmin) { newValue in
                                if let intValue = Int(newValue) {
                                    SettingsManager.shared.seminghrs = intValue
                                }
                            }
                            
                            if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                                NavigationLink(destination: HourPickerView(label: "NS", binding: $viewmodel.seminshrsmin)) {
                                    HStack {
                                        Text("NS")
                                            .font(.system(size: 20))
                                        Spacer()
                                        Text(viewmodel.seminshrsmin)
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                }
                                .onChange(of: viewmodel.seminshrsmin) { newValue in
                                    if let intValue = Int(newValue) {
                                        SettingsManager.shared.seminshrs = intValue
                                    }
                                }
                            }
                            
                            NavigationLink(destination: HourPickerView(label: "Hood/Wx", binding: $viewmodel.semihwxhrsmin)) {
                                HStack {
                                    Text("Hood/Wx")
                                        .font(.system(size: 20))
                                    Spacer()
                                    Text(viewmodel.semihwxhrsmin)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                            .onChange(of: viewmodel.semihwxhrsmin) { newValue in
                                if let intValue = Int(newValue) {
                                    SettingsManager.shared.semihwxhrs = intValue
                                }
                            }
                            
                            if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                                NavigationLink(destination: HourPickerView(label: "Front", binding: $viewmodel.semifronthrsmin)) {
                                    HStack {
                                        Text("Front")
                                            .font(.system(size: 20))
                                        Spacer()
                                        Text(viewmodel.semifronthrsmin)
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                }
                                .onChange(of: viewmodel.semifronthrsmin) { newValue in
                                    if let intValue = Int(newValue) {
                                        SettingsManager.shared.semifronthrs = intValue
                                    }
                                }
                                
                                NavigationLink(destination: HourPickerView(label: "Back", binding: $viewmodel.semibackhrsmin)) {
                                    HStack {
                                        Text("Back")
                                            .font(.system(size: 20))
                                        Spacer()
                                        Text(viewmodel.semibackhrsmin)
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                }
                                .onChange(of: viewmodel.semibackhrsmin) { newValue in
                                    if let intValue = Int(newValue) {
                                        SettingsManager.shared.semibackhrs = intValue
                                    }
                                }
                            }
                        }
                        
                        Section("Annual Sim Hours") {
                            NavigationLink(destination: HourPickerView(label: "Total Sim", binding: $viewmodel.asimhrsmin)) {
                                HStack {
                                    Text("Total Sim")
                                        .font(.system(size: 20))
                                    Spacer()
                                    Text(viewmodel.asimhrsmin)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                            .onChange(of: viewmodel.asimhrsmin) { newValue in
                                if let intValue = Int(newValue) {
                                    SettingsManager.shared.asimhrs = intValue
                                }
                            }
                            
                            if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                                NavigationLink(destination: HourPickerView(label: "Front Sim", binding: $viewmodel.asimfronthrsmin)) {
                                    HStack {
                                        Text("Front Sim")
                                            .font(.system(size: 20))
                                        Spacer()
                                        Text(viewmodel.asimfronthrsmin)
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                }
                                .onChange(of: viewmodel.asimfronthrsmin) { newValue in
                                    if let intValue = Int(newValue) {
                                        SettingsManager.shared.asimfronthrs = intValue
                                    }
                                }
                                
                                NavigationLink(destination: HourPickerView(label: "Back Sim", binding: $viewmodel.asimbackhrsmin)) {
                                    HStack {
                                        Text("Back Sim")
                                            .font(.system(size: 20))
                                        Spacer()
                                        Text(viewmodel.asimbackhrsmin)
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                }
                                .onChange(of: viewmodel.asimbackhrsmin) { newValue in
                                    if let intValue = Int(newValue) {
                                        SettingsManager.shared.asimbackhrs = intValue
                                    }
                                }
                            }
                        }
                        
                        Section("Account") {
                            Button("Logout") {
                                showingLogoutAlert = true
                            }
                            .foregroundColor(.red)
                            
                            Button("Delete Account") {
                                showingDeleteAccount = true
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Confirm Logout"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .destructive(Text("Logout")) {
                            // Action to logout the user
                            viewmodel.logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $showingDeleteAccount) {
                    DeleteAccountView(viewModel: DeleteAccountViewModel())
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for single-column layout on iPad
        }
    }
    
    struct HourPickerView: View {
        var label: String
        @Binding var binding: String
        
        var body: some View {
            VStack {
                Text(label)
                    .bold()
                    .font(.title)
                Picker(selection: $binding, label: Text(label)) {
                    ForEach(0...150, id: \.self) { hour in
                        Text(String(hour))
                            .tag(String(hour)) // Ensure the tag matches the binding type
                    }
                }
                .pickerStyle(WheelPickerStyle()) // Use wheel picker style
                .frame(height: 200) // Adjust height for the wheel picker
                .clipped() // Optional: to avoid overflow if the picker is too tall
                
                Spacer() // Push the picker up
            }
        }
    }
}
