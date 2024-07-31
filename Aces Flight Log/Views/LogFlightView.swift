import SwiftUI

struct LogFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewmodel = LogFlightViewModel()
    @StateObject var pickermodel = pickerlist()

    
    @State private var defaultAircraft: String = ""
    
    @State var isTapped = false

    var body: some View {
        VStack {
            Text("LOG FLIGHT")
                .font(.system(size: 40))
                .bold()
                .padding()
                .foregroundColor(.red)
            HStack{
                Text("Date of Flight")
                    .font(.system(size: 30))
                DatePicker("Select a date", selection: $viewmodel.logdate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .font(.system(size: 30))
            }
            HStack{
                Text("Aircraft")
                    .font(.system(size: 30))
                Picker(selection: $viewmodel.logflightacft, label: Text("Aircraft")) {
                    ForEach(pickermodel.aircraft, id: \.self) { selacft in
                        Text(selacft)
                            .tag(selacft)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onAppear {
                    if let defaultAircraft = SettingsManager.shared.aircraft {
                        // Use the unwrapped value as the default selection
                        self.viewmodel.logflightacft = defaultAircraft
                    } else {
                        // Default to the first item in the aircraft array
                        self.viewmodel.logflightacft = pickermodel.aircraft.first ?? ""
                    }
                }
            }
            HStack{
                Text("Duty")
                    .font(.system(size: 30))
                Picker(selection: $viewmodel.logflightduty, label: Text("Duty")) {
                    ForEach(dutyOptions, id: \.self) { duty in
                        Text(duty)
                            .tag(duty)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            HStack{
                Text("Condition")
                    .font(.system(size: 30))
                Picker(selection: $viewmodel.logflightcondition, label: Text("Condition")) {
                    ForEach(pickermodel.condition, id: \.self) { conditionItem in
                        Text(conditionItem)
                            .tag(conditionItem)
                    }
                }
            }
            
                if viewmodel.logflightacft == "AH-64E" ||
                    viewmodel.logflightacft == "AH-64D" ||
                    (viewmodel.logflightacft == "SIM" &&
                     (SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D")) {
                    HStack{
                    Text("Seat")
                        .font(.system(size: 30))
                    Picker(selection: $viewmodel.logseatposition, label: Text("Seat")) {
                        ForEach(pickermodel.seatAH, id: \.self) { status in
                            Text(status)
                                .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
            }

            HStack{
                Text("Time")
                    .font(.system(size: 30))
                TextField("Enter hours (e.g., ##.#)", text: Binding(
                    get: {
                        // Format the Double value as a String with one decimal place
                        String(format: "%.1f", viewmodel.logflighthrs)
                    },
                    set: { newValue in
                        // Attempt to convert the input String back to a Double
                        if let number = Double(newValue) {
                            // Update the view model's logflighthrs property
                            viewmodel.logflighthrs = number
                        }
                    }
                )).multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(width: 100)
            }.padding()
            
    
            Button(action: {
                if viewmodel.logflightacft != "AH-64E" && viewmodel.logflightacft != "AH-64D" && (viewmodel.logflightacft == "SIM" && (SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D")) {
                    viewmodel.logseatposition = ""
                }
                if viewmodel.canSave {
                    presentationMode.wrappedValue.dismiss()
                    viewmodel.save()
                } else {
                    viewmodel.showAlert = true
                }
            }) {
                Text("LOG FLIGHT")
                    .font(.system(size: 20))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
            .padding(.top, 40)
        }
        .onAppear{
            viewmodel.logflightduty = dutyOptions.first ?? ""
            viewmodel.logflightcondition = pickermodel.condition.first ?? ""
            viewmodel.logseatposition = pickermodel.seatAH.first ?? ""
        }
        .alert(isPresented: $viewmodel.showAlert) {
            Alert(
                title: Text("ERROR"),
                message: Text("Please Fill In All Fields and Select Date Today or Earlier"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    var dutyOptions: [String] {
        let cmStatus = SettingsManager.shared.cmstatus
        switch cmStatus {
        case "RCM":
            return pickermodel.rcmduty
        case "NRCM":
            return pickermodel.nrcmduty
        default:
            return pickermodel.rcmduty // Default to rcmduty if cmstatus is not recognized
        }
    }
}



#Preview {
    LogFlightView()
}
