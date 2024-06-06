import SwiftUI

struct StartPageView: View {
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
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Text("ACES FLIGHT LOG")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                }.padding(.top)
                ScrollView {
                    Text ("TOTALS")
                        .font(.title)
                    VStack {
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.totalHours))")
                        
                        Text("Total NG Hours: \(String(format: "%.1f", firestoreQuery.totalngHours))")
                        
                        Text("Total WX Hours: \(String (format: "%.1f", firestoreQuery.totalwxHours))")
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Total NS Hours: \(String(format: "%.1f", firestoreQuery.totalnsHours))")
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Total Front Seat Hours: \(String(format: "%.1f", firestoreQuery.totalfrontHours))")
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Total Back Seat Hours: \(String(format: "%.1f", firestoreQuery.totalbackHours))")
                        }
                    }
                    // Convert lastNGflight to a string for display
                    if let lastNGFlight = firestoreQuery.lastNGflight {
                        let daysSinceLastNGFlight = Calendar.current.dateComponents([.day], from: lastNGFlight, to: Date()).day ?? 0
                        //Change text to red if >60 days
                        let textColor: Color = daysSinceLastNGFlight > 60 ? .red : .primary
                        Text("Last NG Flight: \(dateFormatter.string(from: lastNGFlight))")
                            .foregroundColor(textColor)
                    }
                    
                    // Conver lastNSflight to a string for display
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D" {
                        if let lastNSFlight = firestoreQuery.lastNSflight {
                            let daysSinceLastNSFlight = Calendar.current.dateComponents([.day], from: lastNSFlight, to: Date()).day ?? 0
                            let textColor: Color = daysSinceLastNSFlight > 60 ? .red : .primary
                            Text("Last NS Flight \(dateFormatter.string(from: lastNSFlight))")
                                .foregroundColor(textColor)
                        }
                    }
                    VStack{
                        Text("SEMIANNUAL")
                            .font(.title)
                        HStack {
                            if let semi1StartDate = firestoreQuery.semi1Start {
                                Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                            } else {
                                Text("Start: Not available")
                            }
                            if let semi1EndDate = firestoreQuery.semi1End {
                                Text("End: \(dateFormatter.string(from: semi1EndDate))")
                            } else {
                                Text("End: Not available")
                            }
                        }
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p1tHours))")
                            .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p1tHours)  ? .red : .primary)
                        
                        Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1hwxHours))")
                            .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p1hwxHours)  ? .red : .primary)
                        
                        Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p1nHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                        
                        Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p1ngHours))")
                            .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p1ngHours)  ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p1nsHours))")
                                .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p1nsHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1frontHours))")
                                .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p1frontHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1backHours))")
                                .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p1backHours)  ? .red : .primary)
                        }
                        
                        Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p1simHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                        
                        Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1simhwxHours))")
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simfrontHours))")
                                .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p1simfrontHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simbackHours))")
                                .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p1simbackHours)  ? .red : .primary)
                        }
                    }.padding()
                    
                    VStack{
                        Text("SEMIANNUAL")
                            .font(.title)
                        HStack {
                            if let semi2StartDate = firestoreQuery.semi2Start {
                                Text("Start: \(dateFormatter.string(from: semi2StartDate))")
                            } else {
                                Text("Start: Not available")
                            }
                            
                            if let semi2EndDate = firestoreQuery.semi2End {
                                Text("End: \(dateFormatter.string(from: semi2EndDate))")
                            } else {
                                Text("End: Not available")
                            }
                        }
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p2tHours))")
                            .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p2tHours)  ? .red : .primary)
                        
                        Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2hwxHours))")
                            .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p2hwxHours) ? .red : .primary)
                        
                        Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p2nHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p2nHours)  ? .red : .primary)
                        
                        Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p2ngHours))")
                            .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p2ngHours)  ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p2nsHours))")
                                .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p2nsHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p2frontHours))")
                                .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p2frontHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p2backHours))")
                                .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p2backHours)  ? .red : .primary)
                        }
                        
                        Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p2simHours))")
                        
                        Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2simhwxHours))")
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Seat Front Hours: \(String(format: "%.1f", firestoreQuery.p2simfrontHours))")
                                .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p2simfrontHours)  ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Seat Back Hours: \(String(format: "%.1f", firestoreQuery.p2simbackHours))")
                                .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p2simbackHours)  ? .red : .primary)
                        }
                    }
                    VStack{
                        Text("ANNUAL PERIOD ")
                            .font(.title)
                        HStack {
                            if let semi1StartDate = firestoreQuery.semi1Start {
                                Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                            } else {
                                Text("Start: Not available")
                            }
                            
                            if let semi2EndDate = firestoreQuery.semi2End {
                                Text("End: \(dateFormatter.string(from: semi2EndDate))")
                            } else {
                                Text("End: Not available")
                            }
                        }
                        
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.AtHours))")
                            .foregroundColor(SettingsManager.shared.semithrs * 2 > Int(firestoreQuery.AtHours) ? .red : .primary)
                        Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.AhwxHours))")
                            .foregroundColor(SettingsManager.shared.semihwxhrs * 2 > Int(firestoreQuery.AhwxHours) ? .red : .primary)
                        
                        Text("Night Hours: \(String(format: "%.1f", firestoreQuery.AnHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs * 2 > Int(firestoreQuery.AnHours) ? .red : .primary)
                        
                        Text("NG Hours: \(String(format: "%.1f", firestoreQuery.AngHours))")
                            .foregroundColor(SettingsManager.shared.seminghrs * 2 > Int(firestoreQuery.AngHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("NS Hours: \(String(format: "%.1f", firestoreQuery.AnsHours))")
                                .foregroundColor(SettingsManager.shared.seminshrs * 2 > Int(firestoreQuery.AnsHours) ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.AfrontHours))")
                                .foregroundColor(SettingsManager.shared.semifronthrs * 2 > Int(firestoreQuery.AfrontHours) ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.AbackHours))")
                                .foregroundColor(SettingsManager.shared.semibackhrs * 2 > Int(firestoreQuery.AbackHours) ? .red : .primary)
                        }
                        
                        Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.AsimHours))")
                            .foregroundColor(SettingsManager.shared.asimhrs > Int(firestoreQuery.AsimHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Front Hours: \(String(format: "%.1f", firestoreQuery.AsimfrontHours))")
                                .foregroundColor(SettingsManager.shared.asimfronthrs > Int(firestoreQuery.AsimfrontHours)  ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Back Hours: \(String(format: "%.1f", firestoreQuery.AsimbackHours))")
                                .foregroundColor(SettingsManager.shared.asimbackhrs > Int(firestoreQuery.AsimbackHours)  ? .red : .primary)
                        }
                        
                    }.padding()
                }
            }
            .onAppear {
                // run update of values when view appears
                firestoreQuery.updateValues()
            }
        } else {
            // for iOS 15 IPAD MINI 4
            ScrollView {
            VStack {
                Text("ACES FLIGHT LOG")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
            }.padding(.top)

                Text ("TOTALS")
                    .font(.title)
                VStack {
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.totalHours))")
                    
                    Text("Total NG Hours: \(String(format: "%.1f", firestoreQuery.totalngHours))")
                    
                    Text("Total WX Hours: \(String (format: "%.1f", firestoreQuery.totalwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total NS Hours: \(String(format: "%.1f", firestoreQuery.totalnsHours))")
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total Front Seat Hours: \(String(format: "%.1f", firestoreQuery.totalfrontHours))")
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Total Back Seat Hours: \(String(format: "%.1f", firestoreQuery.totalbackHours))")
                    }
                }
                // Convert lastNGflight to a string for display
                if let lastNGFlight = firestoreQuery.lastNGflight {
                    let daysSinceLastNGFlight = Calendar.current.dateComponents([.day], from: lastNGFlight, to: Date()).day ?? 0
                    //Change text to red if >60 days
                    let textColor: Color = daysSinceLastNGFlight > 60 ? .red : .primary
                    Text("Last NG Flight: \(dateFormatter.string(from: lastNGFlight))")
                        .foregroundColor(textColor)
                }
                
                // Conver lastNSflight to a string for display
                if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D" {
                    if let lastNSFlight = firestoreQuery.lastNSflight {
                        let daysSinceLastNSFlight = Calendar.current.dateComponents([.day], from: lastNSFlight, to: Date()).day ?? 0
                        let textColor: Color = daysSinceLastNSFlight > 60 ? .red : .primary
                        Text("Last NS Flight \(dateFormatter.string(from: lastNSFlight))")
                            .foregroundColor(textColor)
                    }
                }
                VStack{
                    Text("SEMIANNUAL")
                        .font(.title)
                    HStack {
                        if let semi1StartDate = firestoreQuery.semi1Start {
                            Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                        } else {
                            Text("Start: Not available")
                        }
                        if let semi1EndDate = firestoreQuery.semi1End {
                            Text("End: \(dateFormatter.string(from: semi1EndDate))")
                        } else {
                            Text("End: Not available")
                        }
                    }
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p1tHours))")
                        .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p1tHours)  ? .red : .primary)
                    
                    Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1hwxHours))")
                        .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p1hwxHours)  ? .red : .primary)
                    
                    Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p1nHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                    
                    Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p1ngHours))")
                        .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p1ngHours)  ? .red : .primary)
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p1nsHours))")
                            .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p1nsHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1frontHours))")
                            .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p1frontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1backHours))")
                            .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p1backHours)  ? .red : .primary)
                    }
                    
                    Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p1simHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p1nHours)  ? .red : .primary)
                    
                    Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p1simhwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simfrontHours))")
                            .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p1simfrontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p1simbackHours))")
                            .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p1simbackHours)  ? .red : .primary)
                    }
                }.padding()
                
                VStack{
                    Text("SEMIANNUAL")
                        .font(.title)
                    HStack {
                        if let semi2StartDate = firestoreQuery.semi2Start {
                            Text("Start: \(dateFormatter.string(from: semi2StartDate))")
                        } else {
                            Text("Start: Not available")
                        }
                        
                        if let semi2EndDate = firestoreQuery.semi2End {
                            Text("End: \(dateFormatter.string(from: semi2EndDate))")
                        } else {
                            Text("End: Not available")
                        }
                    }
                    Text("Total Hours: \(String(format: "%.1f", firestoreQuery.p2tHours))")
                        .foregroundColor(SettingsManager.shared.semithrs > Int(firestoreQuery.p2tHours)  ? .red : .primary)
                    
                    Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2hwxHours))")
                        .foregroundColor(SettingsManager.shared.semihwxhrs > Int(firestoreQuery.p2hwxHours) ? .red : .primary)
                    
                    Text("Night Hours: \(String(format: "%.1f", firestoreQuery.p2nHours))")
                        .foregroundColor(SettingsManager.shared.seminhrs > Int(firestoreQuery.p2nHours)  ? .red : .primary)
                    
                    Text("NG Hours: \(String(format: "%.1f", firestoreQuery.p2ngHours))")
                        .foregroundColor(SettingsManager.shared.seminghrs > Int(firestoreQuery.p2ngHours)  ? .red : .primary)
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("NS Hours: \(String(format: "%.1f", firestoreQuery.p2nsHours))")
                            .foregroundColor(SettingsManager.shared.seminshrs > Int(firestoreQuery.p2nsHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.p2frontHours))")
                            .foregroundColor(SettingsManager.shared.semifronthrs > Int(firestoreQuery.p2frontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.p2backHours))")
                            .foregroundColor(SettingsManager.shared.semibackhrs > Int(firestoreQuery.p2backHours)  ? .red : .primary)
                    }
                    
                    Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.p2simHours))")
                    
                    Text("SIM H/WX Hours: \(String(format: "%.1f", firestoreQuery.p2simhwxHours))")
                    
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Seat Front Hours: \(String(format: "%.1f", firestoreQuery.p2simfrontHours))")
                            .foregroundColor(SettingsManager.shared.asimfronthrs / 2 > Int(firestoreQuery.p2simfrontHours)  ? .red : .primary)
                    }
                    if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                        Text("Sim Seat Back Hours: \(String(format: "%.1f", firestoreQuery.p2simbackHours))")
                            .foregroundColor(SettingsManager.shared.asimbackhrs / 2 > Int(firestoreQuery.p2simbackHours)  ? .red : .primary)
                    }
                }
                ScrollView{
                    VStack{
                        Text("ANNUAL PERIOD ")
                            .font(.title)
                        HStack {
                            if let semi1StartDate = firestoreQuery.semi1Start {
                                Text("Start: \(dateFormatter.string(from: semi1StartDate))")
                            } else {
                                Text("Start: Not available")
                            }
                            
                            if let semi2EndDate = firestoreQuery.semi2End {
                                Text("End: \(dateFormatter.string(from: semi2EndDate))")
                            } else {
                                Text("End: Not available")
                            }
                        }
                        
                        Text("Total Hours: \(String(format: "%.1f", firestoreQuery.AtHours))")
                            .foregroundColor(SettingsManager.shared.semithrs * 2 > Int(firestoreQuery.AtHours) ? .red : .primary)
                        Text("H/WX Hours: \(String(format: "%.1f", firestoreQuery.AhwxHours))")
                            .foregroundColor(SettingsManager.shared.semihwxhrs * 2 > Int(firestoreQuery.AhwxHours) ? .red : .primary)
                        
                        Text("Night Hours: \(String(format: "%.1f", firestoreQuery.AnHours))")
                            .foregroundColor(SettingsManager.shared.seminhrs * 2 > Int(firestoreQuery.AnHours) ? .red : .primary)
                        
                        Text("NG Hours: \(String(format: "%.1f", firestoreQuery.AngHours))")
                            .foregroundColor(SettingsManager.shared.seminghrs * 2 > Int(firestoreQuery.AngHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("NS Hours: \(String(format: "%.1f", firestoreQuery.AnsHours))")
                                .foregroundColor(SettingsManager.shared.seminshrs * 2 > Int(firestoreQuery.AnsHours) ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Front Seat Hours: \(String(format: "%.1f", firestoreQuery.AfrontHours))")
                                .foregroundColor(SettingsManager.shared.semifronthrs * 2 > Int(firestoreQuery.AfrontHours) ? .red : .primary)
                        }
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Back Seat Hours: \(String(format: "%.1f", firestoreQuery.AbackHours))")
                                .foregroundColor(SettingsManager.shared.semibackhrs * 2 > Int(firestoreQuery.AbackHours) ? .red : .primary)
                        }
                        
                        Text("SIM Hours: \(String(format: "%.1f", firestoreQuery.AsimHours))")
                            .foregroundColor(SettingsManager.shared.asimhrs > Int(firestoreQuery.AsimHours) ? .red : .primary)
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Front Hours: \(String(format: "%.1f", firestoreQuery.AsimfrontHours))")
                                .foregroundColor(SettingsManager.shared.asimfronthrs > Int(firestoreQuery.AsimfrontHours)  ? .red : .primary)
                        }
                        
                        if SettingsManager.shared.aircraft == "AH-64E" || SettingsManager.shared.aircraft == "AH-64D"{
                            Text("Sim Back Hours: \(String(format: "%.1f", firestoreQuery.AsimbackHours))")
                                .foregroundColor(SettingsManager.shared.asimbackhrs > Int(firestoreQuery.AsimbackHours)  ? .red : .primary)
                        }
                        
                    }.padding()
                }
                .onAppear {
                    // run update of values when view appears
                    firestoreQuery.updateValues()
                }
            }
        }
    }
}
    struct StartPageView_Previews: PreviewProvider {
        static var previews: some View {
            StartPageView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
