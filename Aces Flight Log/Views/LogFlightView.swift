import SwiftUI

struct LogFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewmodel = LogFlightViewModel()
    var aircraft = ["UH-60L", "UH-60M", "HH-60L", "HH-60M", "CH-47", "AH-64E", "AH-64D", "MH-60M", "MH-47G", "UH-72A", "TH-67", "SIM"]
    var rcmduty = ["PI", "PC", "IP", "UT", "MF", "IE", "SP", "ME", "XP"]
    var nrcmduty = ["CE", "SI", "FE", "FI", "OR"]
    var condition = ["D", "N", "NG", "NS", "H", "W"]
    var seatAH = ["F", "B"]
    var seat = ["L", "R"]
    @State private var defaultAircraft: String = ""

    var body: some View {
        VStack {
            Text("LOG FLIGHT")
                .font(.system(size: 40))
                .bold()
                .padding()
            
            Text("Date of Flight")
                .font(.system(size: 30))
            DatePicker("Select a date", selection: $viewmodel.logdate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .font(.system(size: 30))
            
            Text("Aircraft")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightacft, label: Text("Aircraft")) {
                ForEach(aircraft, id: \.self) { selacft in
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
                    self.viewmodel.logflightacft = aircraft.first ?? ""
                }
            }
            
            Text("Duty")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightduty, label: Text("Duty")) {
                ForEach(dutyOptions, id: \.self) { duty in
                    Text(duty)
                        .tag(duty)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Text("Condition")
                .font(.system(size: 30))
            Picker(selection: $viewmodel.logflightcondition, label: Text("Condition")) {
                ForEach(condition, id: \.self) { conditionItem in
                    Text(conditionItem)
                        .tag(conditionItem)
                }
            }
            
            if viewmodel.logflightacft == "AH-64E" || viewmodel.logflightacft == "AH-64D" {
                Text("Seat")
                    .font(.system(size: 30))
                Picker(selection: $viewmodel.logseatposition, label: Text("Seat")) {
                    ForEach(seatAH, id: \.self) { status in
                        Text(status)
                            .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            
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
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .frame(width: 150)
            .padding(.bottom, 20)
            
            Button(action: {
                if viewmodel.canSave {
                    presentationMode.wrappedValue.dismiss()
                    viewmodel.save()
                } else {
                    viewmodel.showAlert = true
                }
            }) {
                Text("SAVE")
                    .font(.system(size: 30))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
        }
        .onAppear{
            viewmodel.logflightduty = dutyOptions.first ?? ""
            viewmodel.logflightcondition = condition.first ?? ""
            viewmodel.logseatposition = seatAH.first ?? ""
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
            return rcmduty
        case "NRCM":
            return nrcmduty
        default:
            return rcmduty // Default to rcmduty if cmstatus is not recognized
        }
    }
}

#Preview {
    LogFlightView()
}
