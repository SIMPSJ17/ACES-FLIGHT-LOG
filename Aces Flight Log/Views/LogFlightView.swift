import SwiftUI
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
            //DOF
            HStack{
                Text("Date of Flight")
                    .font(.system(size: 30))
                DatePicker("Select a date", selection: $viewmodel.logdate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .font(.system(size: 30))
            }
            //AIRCRAFT
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
            //DUTY
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
            //CONDITION
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
            //SEAT
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
            //TIME
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
            CommentsField(logflightcomments: $viewmodel.logflightcomments, characterLimit: 50, pickerLabel: "Comments")
    
            Button(action: {
                if viewmodel.logflightacft != "AH-64E" && viewmodel.logflightacft != "AH-64D"
                    && !(viewmodel.logflightacft == "SIM" && (SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D")) {
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



struct hourspicker: View {
    @StateObject var viewmodel = LogFlightViewModel()
    @State private var selectedHours = 0
    @State private var selectedDecimal = 0 // Decimal fraction in tenths of an hour
    
    // Compute the combined time as a double
    private var combinedTimeAsDouble: Double {
        // Combine hours and decimal part into a double format (e.g., 2 hours and 5 tenths -> 2.5)
        return Double(selectedHours) + Double(selectedDecimal) / 10.0
    }
    
    var body: some View {
        VStack {
            HStack {
                // Picker for Hours
                Picker("Hours", selection: $selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60, height: 100)
                
                Text(".")
                    .font(.system(size: 30))
                
                // Picker for Decimal Representation of tenths of an hour
                Picker("Decimal", selection: $selectedDecimal) {
                    ForEach(0..<10) { decimal in
                        Text(String(format: "%d", decimal)).tag(decimal)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 40, height: 100)
            }
        }
    }
}


struct CommentsField: View {
    @Binding var logflightcomments: String
    var characterLimit: Int
    var pickerLabel: String
    
    @State private var typedCharacters: Int = 0
    @FocusState private var isActive: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                TextField("", text: $logflightcomments)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .focused($isActive)
                    .background(Color.gray.opacity(0.3).cornerRadius(16))
                    .onChange(of: logflightcomments) { newValue in
                        // Update character count
                        typedCharacters = newValue.count
                        
                        // Enforce character limit
                        if newValue.count > characterLimit {
                            logflightcomments = String(newValue.prefix(characterLimit))
                        }
                    }
                    .padding(.horizontal)

                Text(pickerLabel)
                    .padding(.leading)
                    .offset(y: (isActive || !logflightcomments.isEmpty) ? -35 : 0)
                    .animation(.spring(), value: isActive)
                    .onTapGesture {
                        isActive = true
                    }
                    .padding(.horizontal)
            }

            Text("\(typedCharacters) / \(characterLimit)")
                .foregroundColor(.gray)
                .padding(.leading, 240)
        }
    }
}
