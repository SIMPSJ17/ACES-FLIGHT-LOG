import SwiftUI
import UIKit

struct SettingsView: View {
    @StateObject var viewmodel = SettingsViewModel()
    @StateObject var firestoreQuery = Firestorequery(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    @State private var displayedBirthday: String = ""
    @State private var displayedCMStatus: String = ""
    @State private var displayedAircraft: String = ""
    @State private var displayedAthrs: String = ""
    @State private var displayedAnhrs: String = ""
    @State private var displayedAnghrs: String = ""
    @State private var displayedAnshrs: String = ""
    @State private var displayedAhwxhrs: String = ""
    @State private var displayedFronthrs: String = ""
    @State private var displayedBackhrs: String = ""
    @State private var displayedsimhrs: String = ""
    @State private var displayedsimseatFhrs: String = ""
    @State private var displayedsimseatBhrs: String = ""
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccount = false
    
    var aircraft = ["UH-60L", "UH-60M", "HH-60L", "HH-60M", "CH-47", "AH-64E", "AH-64D", "MH-60M", "MH-47G", "UH-72A"]
    var cmstatus = ["RCM", "NRCM"]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Text("SETTINGS")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                    
                    ScrollView {
                        HStack {
                            // Display user settings using @State properties
                            Text(displayedBirthday)
                                .padding()
                            Text(displayedCMStatus)
                                .padding()
                            Text(displayedAircraft)
                                .padding()
                        }
                        .offset(y: -10)
                        Text("Required Hours")
                            .font(.system(size: 30))
                        HStack {
                            Text("Total: \(displayedAthrs)")
                            Text("NVG: \(displayedAnghrs)")
                            if SettingsManager.shared.aircraft == "AH-64E" ||  SettingsManager.shared.aircraft == "AH-64D" {
                                Text("NS: \(displayedAnshrs)")
                            }
                        }
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            HStack{
                                Text("Front: \(displayedFronthrs)")
                                Text("Back: \(displayedBackhrs)")
                            }
                        }
                        HStack {
                            Text("N: \(displayedAnhrs)")
                            Text("H/WX: \(displayedAhwxhrs)")
                            Text("Sim: \(displayedsimhrs)")
                        }
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            HStack {
                                Text("Front Sim: \(displayedsimseatFhrs)")
                                Text("Back Sim: \(displayedsimseatBhrs)")
                            }
                        }
                        Text("Birthday")
                            .font(.system(size: 30))
                            .scenePadding()
                        DatePicker("Select a date", selection: $viewmodel.bday, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                        Text("Rated/NonRated")
                            .font(.system(size: 30))
                        if #available(iOS 17.0, *) {
                            Picker(selection: $viewmodel.cmstatus, label: Text("CM STATUS")) {
                                ForEach(cmstatus, id: \.self) { status in
                                    Text(status)
                                }
                            }.pickerStyle(.palette)
                                .padding(.horizontal)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        Text("AIRCRAFT")
                            .font(.system(size: 30))
                        Picker(selection: $viewmodel.acft, label: Text("Aircraft")) {
                            ForEach(aircraft, id: \.self) { type in
                                Text(type)
                            }
                        }
                        
                        Text("SemiAnnual Requirements")
                            .font(.system(size: 30))
                        HStack {
                            VStack {
                                Text("Total")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semithrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                            
                            VStack {
                                Text("Night")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.seminhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                            
                            VStack {
                                Text("NVG")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.seminghrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                        }
                        
                        HStack {
                            if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                                VStack {
                                    Text("NS")
                                        .font(.system(size: 20))
                                    TextField("0", text: $viewmodel.seminshrsmin)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .frame(width: 50)
                                }.padding(.horizontal)}
                            VStack {
                                Text("H/WX")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semihwxhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                        }
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            HStack {
                                VStack {
                                    Text("Front")
                                        .font(.system(size: 20))
                                    TextField("0", text: $viewmodel.semifronthrsmin)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .frame(width: 50)
                                }.padding(.horizontal)
                                
                                VStack {
                                    Text("Back")
                                        .font(.system(size: 20))
                                    TextField("0", text: $viewmodel.semibackhrsmin)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .frame(width: 50)
                                    
                                }.padding(.horizontal)
                            }
                        }
                        Text("SIM Requirements")
                            .font(.system(size: 30))
                        HStack{
                            VStack {
                                Text("TOTAL SIM")
                                TextField("0", text: $viewmodel.asimhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }
                            if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                                VStack {
                                    Text("Front SIM")
                                        .font(.system(size: 20))
                                    TextField("0", text: $viewmodel.asimfronthrsmin)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .frame(width: 50)
                                }
                                VStack {
                                    Text("Back SIM")
                                        .font(.system(size: 20))
                                    TextField("0", text: $viewmodel.asimbackhrsmin)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .frame(width: 50)
                                }
                            }
                        }
                        .scenePadding()
                        albutton(title: "UPDATE", bgroundcolor: .red, action: {
                            // Update SettingsManager with new values from viewmodel
                            SettingsManager.shared.birthday = viewmodel.bday
                            SettingsManager.shared.cmstatus = viewmodel.cmstatus
                            SettingsManager.shared.aircraft = viewmodel.acft
                            SettingsManager.shared.semithrs = Int(viewmodel.semithrsmin) ?? 0
                            SettingsManager.shared.seminhrs = Int(viewmodel.seminhrsmin) ?? 0
                            SettingsManager.shared.seminghrs = Int(viewmodel.seminghrsmin) ?? 0
                            SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                            SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                            SettingsManager.shared.semifronthrs = Int(viewmodel.semifronthrsmin) ?? 0
                            SettingsManager.shared.semibackhrs = Int(viewmodel.semibackhrsmin) ?? 0
                            SettingsManager.shared.semihwxhrs = Int(viewmodel.semihwxhrsmin) ?? 0
                            SettingsManager.shared.asimhrs = Int(viewmodel.asimhrsmin) ?? 0
                            firestoreQuery.updateValues()
                            SettingsManager.shared.asimfronthrs = Int(viewmodel.asimfronthrsmin) ?? 0
                            firestoreQuery.updateValues()
                            SettingsManager.shared.asimbackhrs = Int(viewmodel.asimbackhrsmin) ?? 0
                            firestoreQuery.updateValues()
                            // Update displayed settings
                            updateDisplayedSettings()
                            // Dismiss keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        })
                        .font(.system(size: 30))
                        .offset(y: -20)
                        .padding(.horizontal)
                        .padding(.vertical)
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
                .onAppear {
                    // Initialize displayed settings on view load
                    updateDisplayedSettings()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            Text("LOGOUT")
                                .font(.callout)
                                .padding()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingDeleteAccount = true
                        }) {
                            Text("Delete Account")
                                .font(.callout)
                                .padding()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDeleteAccount) {
                DeleteAccountView(viewModel: DeleteAccountViewModel())
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions

                ScrollView {
                    HStack{
                        Button("Logout") {
                            showingLogoutAlert = true
                        }.padding()
                        Text("Settings")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.red)
                            .padding()
                        Button("Delete Account") {
                            showingDeleteAccount = true
                        }
                    }
                    HStack {
                        // Display user settings using @State properties
                        Text(displayedBirthday)
                            .padding()
                        Text(displayedCMStatus)
                            .padding()
                        Text(displayedAircraft)
                            .padding()
                    }
                    .offset(y: -10)
                    Text("Required Hours")
                        .font(.system(size: 30))
                    HStack {
                        Text("Total: \(displayedAthrs)")
                        Text("NVG: \(displayedAnghrs)")
                        if SettingsManager.shared.aircraft == "AH-64E" ||  SettingsManager.shared.aircraft == "AH-64D" {
                            Text("NS: \(displayedAnshrs)")
                        }
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack{
                            Text("Front: \(displayedFronthrs)")
                            Text("Back: \(displayedBackhrs)")
                        }
                    }
                    HStack {
                        Text("N: \(displayedAnhrs)")
                        Text("H/WX: \(displayedAhwxhrs)")
                        Text("Sim: \(displayedsimhrs)")
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack {
                            Text("Front Sim: \(displayedsimseatFhrs)")
                            Text("Back Sim: \(displayedsimseatBhrs)")
                        }
                    }
                    Text("Birthday")
                        .font(.system(size: 30))
                        .scenePadding()
                    DatePicker("Select a date", selection: $viewmodel.bday, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    Text("Rated/NonRated")
                        .font(.system(size: 30))
                    if #available(iOS 17.0, *) {
                        Picker(selection: $viewmodel.cmstatus, label: Text("CM STATUS")) {
                            ForEach(cmstatus, id: \.self) { status in
                                Text(status)
                            }
                        }.pickerStyle(.palette)
                            .padding(.horizontal)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Text("AIRCRAFT")
                        .font(.system(size: 30))
                    Picker(selection: $viewmodel.acft, label: Text("Aircraft")) {
                        ForEach(aircraft, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    Text("SemiAnnual Requirements")
                        .font(.system(size: 30))
                    HStack {
                        VStack {
                            Text("Total")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.semithrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                        
                        VStack {
                            Text("Night")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.seminhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                        
                        VStack {
                            Text("NVG")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.seminghrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                    }
                    
                    HStack {
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            VStack {
                                Text("NS")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.seminshrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)}
                        VStack {
                            Text("H/WX")
                                .font(.system(size: 20))
                            TextField("0", text: $viewmodel.semihwxhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }.padding(.horizontal)
                    }
                    if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                        HStack {
                            VStack {
                                Text("Front")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semifronthrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }.padding(.horizontal)
                            
                            VStack {
                                Text("Back")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.semibackhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                                
                            }.padding(.horizontal)
                        }
                    }
                    Text("SIM Requirements")
                        .font(.system(size: 30))
                    HStack{
                        VStack {
                            Text("TOTAL SIM")
                            TextField("0", text: $viewmodel.asimhrsmin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .frame(width: 50)
                        }
                        if viewmodel.acft == "AH-64E" || viewmodel.acft == "AH-64D" {
                            VStack {
                                Text("Front SIM")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.asimfronthrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }
                            VStack {
                                Text("Back SIM")
                                    .font(.system(size: 20))
                                TextField("0", text: $viewmodel.asimbackhrsmin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .frame(width: 50)
                            }
                        }
                    }
                    .scenePadding()
                    albutton(title: "UPDATE", bgroundcolor: .red, action: {
                        // Update SettingsManager with new values from viewmodel
                        SettingsManager.shared.birthday = viewmodel.bday
                        SettingsManager.shared.cmstatus = viewmodel.cmstatus
                        SettingsManager.shared.aircraft = viewmodel.acft
                        SettingsManager.shared.semithrs = Int(viewmodel.semithrsmin) ?? 0
                        SettingsManager.shared.seminhrs = Int(viewmodel.seminhrsmin) ?? 0
                        SettingsManager.shared.seminghrs = Int(viewmodel.seminghrsmin) ?? 0
                        SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                        SettingsManager.shared.seminshrs = Int(viewmodel.seminshrsmin) ?? 0
                        SettingsManager.shared.semifronthrs = Int(viewmodel.semifronthrsmin) ?? 0
                        SettingsManager.shared.semibackhrs = Int(viewmodel.semibackhrsmin) ?? 0
                        SettingsManager.shared.semihwxhrs = Int(viewmodel.semihwxhrsmin) ?? 0
                        SettingsManager.shared.asimhrs = Int(viewmodel.asimhrsmin) ?? 0
                        firestoreQuery.updateValues()
                        SettingsManager.shared.asimfronthrs = Int(viewmodel.asimfronthrsmin) ?? 0
                        firestoreQuery.updateValues()
                        SettingsManager.shared.asimbackhrs = Int(viewmodel.asimbackhrsmin) ?? 0
                        firestoreQuery.updateValues()
                        // Update displayed settings
                        updateDisplayedSettings()
                        // Dismiss keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .font(.system(size: 30))
                    .offset(y: -20)
                    .padding(.horizontal)
                    .padding(.vertical)
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
            .onAppear {
                // Initialize displayed settings on view load
                updateDisplayedSettings()
            }
            .sheet(isPresented: $showingDeleteAccount) {
            DeleteAccountView(viewModel: DeleteAccountViewModel())
            }
        }
    }
    // update displayed settings
    private func updateDisplayedSettings() {
        displayedBirthday = formattedDate(SettingsManager.shared.birthday)
        displayedCMStatus = SettingsManager.shared.cmstatus ?? ""
        displayedAircraft = SettingsManager.shared.aircraft ?? ""
        displayedAthrs = String(SettingsManager.shared.semithrs)
        displayedAnhrs = String(SettingsManager.shared.seminhrs)
        displayedAnghrs = String(SettingsManager.shared.seminghrs)
        displayedAnshrs = String(SettingsManager.shared.seminshrs)
        displayedFronthrs = String(SettingsManager.shared.semifronthrs)
        displayedBackhrs = String(SettingsManager.shared.semibackhrs)
        displayedAhwxhrs = String(SettingsManager.shared.semihwxhrs)
        displayedsimhrs = String(SettingsManager.shared.asimhrs)
        displayedsimseatFhrs = String(SettingsManager.shared.asimfronthrs)
        displayedsimseatBhrs = String(SettingsManager.shared.asimbackhrs)
    }
    
    //format Date into String
    private func formattedDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
