import SwiftUI

struct CardView: View {
    // Initialize Firestorequery directly in StartPageView
    @StateObject var firestoreQuery: Firestorequery
    
    init(userId: String) {
        _firestoreQuery = StateObject(wrappedValue: Firestorequery(userId: userId))
    }
    // DateFormatter to format the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack{
            Text("ACES FLIGHT LOG")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.red)
                .padding(.top, 50)
            TabView{
                totalcardview(firestoreQuery: firestoreQuery)
                
                semiperiod1view(firestoreQuery: firestoreQuery)
                
                semiperiod2view(firestoreQuery: firestoreQuery)
                
                annualperiodview(firestoreQuery: firestoreQuery)
            }.tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onAppear {
                firestoreQuery.updateValues()
            }
        }
    }
}

struct totalcardview: View {
    @StateObject var firestoreQuery: Firestorequery
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack {
            if let aircraft = SettingsManager.shared.aircraft {
                if aircraft.contains("60") {
                    // Display image for uh60
                    Image("uh60")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 200, height: 200) // Adjust size as needed
                } else if aircraft.contains("64") {
                    // Display image for ah64
                    Image("ah64")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 200, height: 200) // Adjust size as needed
                } else if aircraft.contains("47") {
                    // Display image for ch47
                    Image("ch47")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 200, height: 200) // Adjust size as needed
                } else if aircraft.contains("72") {
                    // Display image for uh72
                    Image("uh72")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 200, height: 200) // Adjust size as needed
                }
            }

          Text ("TOTAL")
              .font(.title)
              Text("Total Hours: \(String(format: "%.1f", firestoreQuery.totalHours))")
                .font(.title2)
              
              Text("Total NG Hours: \(String(format: "%.1f", firestoreQuery.totalngHours))")
                .font(.title2)
              
              Text("Total WX Hours: \(String (format: "%.1f", firestoreQuery.totalwxHours))")
                .font(.title2)
              if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                  Text("Total NS Hours: \(String(format: "%.1f", firestoreQuery.totalnsHours))").font(.title2)
              }
            
              if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                  Text("Total Front Seat Hours: \(String(format: "%.1f", firestoreQuery.totalfrontHours))").font(.title2)
              }
              if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                  Text("Total Back Seat Hours: \(String(format: "%.1f", firestoreQuery.totalbackHours))").font(.title2)
          }
          // Convert lastNGflight to a string for display
          if let lastNGFlight = firestoreQuery.lastNGflight {
              let daysSinceLastNGFlight = Calendar.current.dateComponents([.day], from: lastNGFlight, to: Date()).day ?? 0
              //Change text to red if >60 days
              let textColor: Color = daysSinceLastNGFlight > 60 ? .red : .primary
              Text("Last NG Flight: \(dateFormatter.string(from: lastNGFlight))")
                  .foregroundColor(textColor)
                  .font(.title2)
          }
          // Conver lastNSflight to a string for display
          if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D" {
              if let lastNSFlight = firestoreQuery.lastNSflight {
                  let daysSinceLastNSFlight = Calendar.current.dateComponents([.day], from: lastNSFlight, to: Date()).day ?? 0
                  let textColor: Color = daysSinceLastNSFlight > 60 ? .red : .primary
                  Text("Last NS Flight \(dateFormatter.string(from: lastNSFlight))")
                      .foregroundColor(textColor)
                      .font(.title2)
              }
            }
        }
    }
}

struct semiperiod1view: View {
    @StateObject var firestoreQuery: Firestorequery
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack{
            Text("SEMIANNUAL")
                .font(.title)
            HStack {
                if let semi1StartDate = firestoreQuery.semi1Start {
                    Text("Start: \(dateFormatter.string(from: semi1StartDate))").font(.title2)
                } else {
                    Text("Start: Not available")
                }
                if let semi1EndDate = firestoreQuery.semi1End {
                    Text("End: \(dateFormatter.string(from: semi1EndDate))").font(.title2)
                } else {
                    Text("End: Not available")
                }
            }
            Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p1tHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p1tHours)  ? .red : .primary)
            
            Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1hwxHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p1hwxHours)  ? .red : .primary)
            
            Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p1nHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
            
            Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p1ngHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p1ngHours)  ? .red : .primary)
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p1nsHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p1nsHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1frontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p1frontHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1backHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p1backHours)  ? .red : .primary)
            }
            
            Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p1simHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.asimhrs / 2 > Int(firestoreQuery.p1simHours) ? .red : .primary)
            
            Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1simhwxHours))")
                .font(.title2)
                
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simfrontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p1simfrontHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simbackHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p1simbackHours)  ? .red : .primary)
            }
        }.padding()
    }
}

struct semiperiod2view: View {
    @StateObject var firestoreQuery: Firestorequery
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    var body: some View{
        VStack{
            Text("SEMIANNUAL")
                .font(.title)
            HStack {
                if let semi2StartDate = firestoreQuery.semi2Start {
                    Text("Start: \(dateFormatter.string(from: semi2StartDate))")
                        .font(.title2)
                } else {
                    Text("Start: Not available")
                        .font(.title2)
                }
                
                if let semi2EndDate = firestoreQuery.semi2End {
                    Text("End: \(dateFormatter.string(from: semi2EndDate))").font(.title2)
                } else {
                    Text("End: Not available")
                        .font(.title2)
                }
            }
            Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p2tHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p2tHours)  ? .red : .primary)
            
            Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2hwxHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p2hwxHours) ? .red : .primary)
            
            Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p2nHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p2nHours)  ? .red : .primary)
            
            Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p2ngHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p2ngHours)  ? .red : .primary)
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p2nsHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p2nsHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p2frontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p2frontHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p2backHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p2backHours)  ? .red : .primary)
            }
            
            Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p2simHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.asimhrs / 2 > Int(firestoreQuery.p2simHours) ? .red : .primary)
            
            Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2simhwxHours))")
                .font(.title2)
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Seat Front Hours: \(String(format: "%.1f", firestoreQuery.p2simfrontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p2simfrontHours)  ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Seat Back Hours: \(String(format: "%.1f", firestoreQuery.p2simbackHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p2simbackHours)  ? .red : .primary)
            }
        }
    }
}

struct annualperiodview: View {
    @StateObject var firestoreQuery: Firestorequery
    
    // DateFormatter to format the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    var body: some View {
        VStack{
            Text("ANNUAL PERIOD ")
                .font(.title)
            HStack {
                if let semi1StartDate = firestoreQuery.semi1Start {
                    Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                        .font(.title2)
                } else {
                    Text("Start: Not available")
                        .font(.title2)
                }
                
                if let semi2EndDate = firestoreQuery.semi2End {
                    Text("End: \(dateFormatter.string(from: semi2EndDate))")
                        .font(.title2)
                } else {
                    Text("End: Not available")
                        .font(.title2)
                }
            }
            
            Text("Total Hours: \(String(format: "%.1f", firestoreQuery.AtHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semithrs * 2 > Int(firestoreQuery.AtHours) ? .red : .primary)
            Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.AhwxHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.semihwxhrs * 2 > Int(firestoreQuery.AhwxHours) ? .red : .primary)
            
            Text("Night Hours: \(String(format: "%.1f", firestoreQuery.AnHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminhrs * 2 > Int(firestoreQuery.AnHours) ? .red : .primary)
            
            Text("NG Hours: \(String(format: "%.1f", firestoreQuery.AngHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.seminghrs * 2 > Int(firestoreQuery.AngHours) ? .red : .primary)
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("NS Hours: \(String(format: "%.1f", firestoreQuery.AnsHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.seminshrs * 2 > Int(firestoreQuery.AnsHours) ? .red : .primary)
            }
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.AfrontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semifronthrs * 2 > Int(firestoreQuery.AfrontHours) ? .red : .primary)
            }
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.AbackHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.semibackhrs * 2 > Int(firestoreQuery.AbackHours) ? .red : .primary)
            }
            
            Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.AsimHours))")
                .font(.title2)
                .foregroundColor(SettingsManager.shared.asimhrs > Int(firestoreQuery.AsimHours) ? .red : .primary)
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Front Hours: \(String(format: "%.1f", firestoreQuery.AsimfrontHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimfronthrs > Int(firestoreQuery.AsimfrontHours)  ? .red : .primary)
            }
            
            if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                Text("Sim Back Hours: \(String(format: "%.1f", firestoreQuery.AsimbackHours))")
                    .font(.title2)
                    .foregroundColor(SettingsManager.shared.asimbackhrs > Int(firestoreQuery.AsimbackHours)  ? .red : .primary)
            }
            
        }.padding()
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
