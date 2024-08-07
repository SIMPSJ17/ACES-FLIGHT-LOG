import SwiftUI

struct EditFlightLogView: View {
    @ObservedObject var viewModel: EditFlightLogViewModel
    //is used to pull list of aircraft 
    @StateObject var pickermodel = pickerlist()
    //used to call the dismiss function for the view
    @Environment(\.presentationMode) var presentationMode
 
    
    var body: some View {
        VStack {
            Text("Edit Flight Log")
                .font(.title)
                .bold()
                .padding()
                .foregroundColor(.red)
            
            // Date of Flight
            HStack {
                Text("Date of Flight")
                    .font(.system(size: 30))
                DatePicker("", selection: $viewModel.dof, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .font(.system(size: 30))
            }
            .padding(.horizontal)
            
            // Aircraft
            HStack {
                Text("Aircraft")
                    .font(.system(size: 30))
                Picker("Aircraft", selection: $viewModel.acft) {
                    ForEach(pickermodel.aircraft, id: \.self) { selacft in
                        Text(selacft)
                            .tag(selacft)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            
            // Duty
            HStack {
                Text("Duty")
                    .font(.system(size: 30))
                Picker("Duty", selection: $viewModel.duty) {
                    ForEach(dutyOptions, id: \.self) { duty in
                        Text(duty)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            
            // Condition
            HStack {
                Text("Condition")
                    .font(.system(size: 30))
                Picker("Condition", selection: $viewModel.condition) {
                    ForEach(pickermodel.condition, id: \.self) { conditionItem in
                        Text(conditionItem)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            
            // Seat (conditional)
            if viewModel.acft == "AH-64E" ||
                viewModel.acft == "AH-64D" ||
                (viewModel.acft == "SIM" &&
                 (SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D")) {
                HStack {
                    Text("Seat")
                        .font(.system(size: 30))
                    Picker("Seat", selection: $viewModel.seat) {
                        ForEach(pickermodel.seatAH, id: \.self) { status in
                            Text(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)
            }
            
            // Hours
            HStack{
                Text("Time")
                    .font(.system(size: 30))
                TextField("Enter hours (e.g., ##.#)", text: Binding(
                    get: {
                        // Format the Double value as a String with one decimal place
                        String(format: "%.1f", viewModel.hours)
                    },
                    set: { newValue in
                        // Attempt to convert the input String back to a Double
                        if let number = Double(newValue) {
                            // Update the view model's logflighthrs property
                            viewModel.hours = number
                        }
                    }
                )).multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(width: 100)
            }.padding()
            
            // Comments
            CommentsField(logflightcomments: $viewModel.comments, characterLimit: 50, pickerLabel: "Comments")
            
            // Save Changes Button
            Button(action: {
                viewModel.update()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("SAVE CHANGES")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to update flight log."),
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
