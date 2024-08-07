import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class Firestorequery: ObservableObject {
    @StateObject var pickermodel = pickerlist()
    @Published var items: [FlightLogItem] = []
    @Published var totalHours: Double = 0.0
    @Published var totalngHours: Double = 0.0
    @Published var totalnsHours: Double = 0.0
    @Published var totalwxHours: Double = 0.0
    @Published var totalfrontHours: Double = 0.0
    @Published var totalbackHours: Double = 0.0
    @Published var lastNGflight: Date?
    @Published var lastNSflight: Date?
    @Published var p1tHours: Double = 0.0
    @Published var p1ngHours: Double = 0.0
    @Published var p1nsHours: Double = 0.0
    @Published var p1hwxHours: Double = 0.0
    @Published var p1nHours: Double = 0.0
    @Published var p1frontHours: Double = 0.0
    @Published var p1backHours: Double = 0.0
    @Published var p1simHours: Double = 0.0
    @Published var p1simfrontHours: Double = 0.0
    @Published var p1simbackHours: Double = 0.0
    @Published var p1simhwxHours: Double = 0.0
    @Published var p2tHours: Double = 0.0
    @Published var p2ngHours: Double = 0.0
    @Published var p2nsHours: Double = 0.0
    @Published var p2hwxHours: Double = 0.0
    @Published var p2nHours: Double = 0.0
    @Published var p2simHours: Double = 0.0
    @Published var p2simfrontHours: Double = 0.0
    @Published var p2simbackHours: Double = 0.0
    @Published var p2simhwxHours: Double = 0.0
    @Published var p2frontHours: Double = 0.0
    @Published var p2backHours: Double = 0.0
    @Published var AtHours: Double = 0.0
    @Published var AngHours: Double = 0.0
    @Published var AnsHours: Double = 0.0
    @Published var AhwxHours: Double = 0.0
    @Published var AnHours: Double = 0.0
    @Published var AfrontHours: Double = 0.0
    @Published var AbackHours: Double = 0.0
    @Published var AsimHours: Double = 0.0
    @Published var AsimfrontHours: Double = 0.0
    @Published var AsimbackHours: Double = 0.0
    @Published var upcomingBirthday: Date?
    @Published var semi1Start: Date?
    @Published var semi1End: Date?
    @Published var semi2Start: Date?
    @Published var semi2End: Date?
    let viewmodel = SettingsViewModel()

    var aircraft = ["UH-60L", "UH-60M", "UH-60V", "HH-60L", "HH-60M", "CH-47", "CH-47D", "CH-47F", "CH-47G" ,"AH-64E", "AH-64D", "MH-60M", "MH-47G", "MH-47E", "UH-72", "UH-72A", "TH-67", "TH-67A", "OH-58A", "OH-58B", "OH-58C", "OH-58D", "OH-58", "OH-6", "MH-6", "OH-6A", "AH-6"]
    var rcmduty = ["PI", "PC", "IP", "UT", "MF", "IE", "SP", "ME", "XP"]
    var nrcmduty = ["CE", "SI", "FE", "FI", "OR"]
    var userId: String
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    //check the DB version it has then runs the add comments function
    init(userId: String) {
        self.userId = userId
        print(SettingsManager.shared.DBversion)
        if SettingsManager.shared.DBversion < 3 {
            addCommentsFieldToFlightLogs {
                self.fetchData(userId: userId)
            }
        } else {
            fetchData(userId: userId)
            print(SettingsManager.shared.DBversion)
        }
        print(SettingsManager.shared.DBversion)
    }
    //Is used to delete flighlog items that is saved as a map in the DB
    func delete(id: String) {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        let collectionRef = db.collection("users/\(uId)/FlightLog")
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error finding document: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            for document in documents {
                var logs = document.data()["logs"] as? [[String: Any]] ?? []
                if let index = logs.firstIndex(where: { $0["id"] as? String == id }) {
                    logs.remove(at: index)
                    collectionRef.document(document.documentID).updateData(["logs": logs]) { error in
                        if let error = error {
                            print("Error deleting log: \(error.localizedDescription)")
                        } else {
                            print("Log deleted successfully.")
                        }
                    }
                }
            }
        }
    }
    //fetches all the documents in the collection flightlog then decodes the json into flightlogitems
    func fetchData(userId: String) {
        let collectionRef = db.collection("users").document(userId).collection("FlightLog")
        
        // Add snapshot listener to listen for changes in the collection
        listener = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            self.items.removeAll()
            for document in querySnapshot!.documents {
                let data = document.data() // Retrieve the entire document
                
                guard let logs = data["logs"] as? [[String: Any]] else {
                    print("Error: logs field is not formatted as expected.")
                    continue
                }
                
                for logData in logs {
                    do {
                        // Decode each log entry from JSON to FlightLogItem
                        let jsonData = try JSONSerialization.data(withJSONObject: logData)
                        let flightLog = try JSONDecoder().decode(FlightLogItem.self, from: jsonData)
                        self.items.append(flightLog)
                    } catch let error {
                        print("Error decoding flight log entry: \(error.localizedDescription)")
                    }
                }
            }
            
            // Sort the items by date of flight in descending order
            self.items.sort(by: { $0.dof > $1.dof })
            print(items)
            updateValues()
        }
    }
    
    //func used to update vaules when a flight is logged
    func updateValues() {
        calculateDates()
        totalHours = calculateTotalHours()
        totalngHours = calculateTotalNGHours()
        totalnsHours = calculateTotalNSHours()
        totalwxHours = calculateTotalWXHours()
        totalfrontHours = calculatetotalfrontHours()
        totalbackHours = calculatetotalbackHours()
        lastNGflight = findLastNGFlight()
        lastNSflight = findLastNSFlight()
        p1tHours = calculateP1tHours()
        p1ngHours = calculateP1ngHours()
        p1nsHours = calculateP1nsHours()
        p1hwxHours = calculateP1hwxHours()
        p1nHours = calculateP1nHours()
        p1frontHours = calculateP1frontHours()
        p1backHours = calculateP1backHours()
        p1simHours = calculateP1simHours()
        p1simfrontHours = calculateP1simfrontHours()
        p1simbackHours = calculateP1simbackHours()
        p1simhwxHours = calculateP1simhwxHours()
        p2tHours = calculateP2tHours()
        p2ngHours = calculateP2ngHours()
        p2nsHours = calculateP2nsHours()
        p2hwxHours = calculateP2hwxHours()
        p2nHours = calculateP2nHours()
        p2frontHours = calculateP2frontHours()
        p2backHours = calculateP2backHours()
        p2simHours = calculateP2simHours()
        p2simfrontHours = calculateP2simfrontHours()
        p2simbackHours = calculateP2simbackHours()
        p2simhwxHours = calculateP2simhwxHours()
        AtHours = calculateAtHours()
        AngHours = calculateAngHours()
        AnsHours = calculateAnsHours()
        AnHours = calculateAnHours()
        AfrontHours = calculateAfrontHours()
        AbackHours = calculateAbackHours()
        AhwxHours = calculateAhwxHours()
        AsimHours = calculateAsimHours()
        AsimfrontHours = calculateAsimfrontHours()
        AsimbackHours = calculateAsimbackHours()
    }

    private func calculateTotalHours() -> Double {
        let totalItems = filterItemsByAllowedAircraft(items)
        return totalItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateTotalNGHours() -> Double {
        let ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" }
        return ngItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculatetotalfrontHours() -> Double {
        let frontItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "F" && ($0.acft == "AH-64E" || $0.acft == "AH-64D")}
        return frontItems.reduce(0.0) {$0 + $1.hours}
    }
    
    private func calculatetotalbackHours() -> Double {
        let backItems = filterItemsByAllowedAircraft(items).filter { $0.seat == "B" && ($0.acft == "AH-64E" || $0.acft == "AH-64D")}
        return backItems.reduce(0.0) {$0 + $1.hours}
    }
    
    private func calculateTotalWXHours() -> Double {
        let wxItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "W" }
        return wxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateTotalNSHours() -> Double {
        let nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" }
        return nsItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func findLastNGFlight() -> Date? {
        let ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" }
        guard let lastNGItem = ngItems.max(by: { $0.dof < $1.dof }) else {
            return nil
        }
        return Date(timeIntervalSince1970: lastNGItem.dof)
    }
    
    private func findLastNSFlight() -> Date? {
        let nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" }
        guard let lastNSItem = nsItems.max(by: { $0.dof < $1.dof }) else {
            return nil
        }
        return Date(timeIntervalSince1970: lastNSItem.dof)
    }
    
    private func calculateP1tHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1tItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1tItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1ngHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1ngItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1nsHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970}
        return p1nsItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1nHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1nItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "N" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1nItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1frontHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1frontItems = filterItemsByAllowedAircraft(items).filter { ($0.seat == "F") && ($0.dof >= startDate.timeIntervalSince1970) && ($0.dof <= endDate.timeIntervalSince1970) && ($0.acft == "AH-64E" || $0.acft == "AH-64D") }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1backHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1backItems = filterItemsByAllowedAircraft(items).filter { ($0.seat == "B") && ($0.dof >= startDate.timeIntervalSince1970) && ($0.dof <= endDate.timeIntervalSince1970) && ($0.acft == "AH-64E" || $0.acft == "AH-64D")}
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1hwxHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1hwxItems = filterItemsByAllowedAircraft(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1simItems = filterItemsBySim(items)
            .filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        
        return p1simItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simhwxHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1hwxItems = filterItemsBySim(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simfrontHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1frontItems = filterItemsBySim(items).filter { ($0.seat == "F") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970  }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP1simbackHours() -> Double {
        guard let startDate = semi1Start, let endDate = semi1End else {
            return 0.0
        }
        let p1backItems = filterItemsBySim(items).filter { ($0.seat == "B") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2tHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2tItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2tItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2ngHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2ngItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NG" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2ngItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2nsHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2nsItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "NS" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2nsItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2frontHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2frontItems = filterItemsByAllowedAircraft(items).filter { ($0.seat == "F") && ($0.dof >= startDate.timeIntervalSince1970) && ($0.dof <= endDate.timeIntervalSince1970) && ($0.acft == "AH-64E" || $0.acft == "AH-64D")}
        return p2frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2backHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2backItems = filterItemsByAllowedAircraft(items).filter { ($0.seat == "B") && ($0.dof >= startDate.timeIntervalSince1970) && ($0.dof <= endDate.timeIntervalSince1970) && ($0.acft == "AH-64E" || $0.acft == "AH-64D")}
        return p2backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2nHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2nItems = filterItemsByAllowedAircraft(items).filter { $0.condition == "N" && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2nItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2hwxHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2hwxItems = filterItemsByAllowedAircraft(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2simItems = filterItemsBySim(items)
            .filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        
        return p2simItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simhwxHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p2hwxItems = filterItemsBySim(items).filter { ($0.condition == "H" || $0.condition == "W") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p2hwxItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simfrontHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p1frontItems = filterItemsBySim(items).filter { ($0.seat == "F") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1frontItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateP2simbackHours() -> Double {
        guard let startDate = semi2Start, let endDate = semi2End else {
            return 0.0
        }
        let p1backItems = filterItemsBySim(items).filter { ($0.seat == "B") && $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return p1backItems.reduce(0.0) { $0 + $1.hours }
    }
    
    private func calculateAtHours() -> Double {
        return p1tHours + p2tHours
    }
    
    private func calculateAngHours() -> Double {
        return p1ngHours + p2ngHours
    }
    
    private func calculateAnsHours() -> Double {
        return p1nsHours + p2nsHours
    }
    
    private func calculateAnHours() -> Double {
        return p1nHours + p2nHours
    }
    
    private func calculateAfrontHours() -> Double{
        return p1frontHours + p2frontHours
    }
    
    private func calculateAbackHours() -> Double{
        return p1backHours + p2backHours
    }
    
    private func calculateAhwxHours() -> Double {
        return p1hwxHours + p2hwxHours
    }
    
    private func calculateAsimHours() -> Double {
        return p1simHours + p2simHours
    }
    
    private func calculateAsimfrontHours() -> Double {
        return p1simfrontHours + p2simfrontHours
    }
    
    private func calculateAsimbackHours() -> Double {
        return p1simbackHours + p2simbackHours
    }
    
    private func totalHours(inDateRange startDate: Date, endDate: Date) -> Double {
        let filteredItems = filterItemsByAllowedAircraft(items).filter { $0.dof >= startDate.timeIntervalSince1970 && $0.dof <= endDate.timeIntervalSince1970 }
        return filteredItems.reduce(0.0) { $0 + $1.hours }
    }
    
    func calculateDates() {
        guard let birthday = SettingsManager.shared.birthday else {
            print("No birthday set in SettingsManager")
            self.upcomingBirthday = nil
            self.semi1Start = nil
            self.semi1End = nil
            self.semi2Start = nil
            self.semi2End = nil
            return
        }
        print(birthday)
        
        var calendar = Calendar.current
        let timeZone = TimeZone.current
        calendar.timeZone = timeZone
        
        // Calculate the next birthday date based on today's date
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        // Create the next birthday date using the current year
        guard var nextBirthday = calendar.date(from: DateComponents(year: todayComponents.year, month: birthdayComponents.month, day: birthdayComponents.day)) else {
            print("Failed to compute next birthday")
            return
        }
        
        // Adjust next birthday if it has already passed or if the next birthday month is greater than the current month
        if birthdayComponents.month! < todayComponents.month! {
            nextBirthday = calendar.date(byAdding: .year, value: 1, to: nextBirthday)!
        }
        
        print("Next birthday: \(nextBirthday)")
        
        // Add one month to the next birthday and set the day to 1
        var components = DateComponents()
        components.month = 1
        components.day = -calendar.component(.day, from: nextBirthday) + 1
        
        guard let firstDayOfFollowingMonth = calendar.date(byAdding: components, to: nextBirthday) else {
            print("Failed to compute first day of the following month")
            return
        }
        
        print("First day of the month following the next birthday: \(firstDayOfFollowingMonth)")
        
        guard let lastDayOfBirthdayMonth = calendar.date(byAdding: DateComponents(day: -1), to: firstDayOfFollowingMonth) else {
            print("Failed to compute last day of the birthday month")
            return
        }
        
        print("Last day of the month following the next birthday: \(lastDayOfBirthdayMonth)")
        
        self.semi2End = lastDayOfBirthdayMonth
        print("Semi2 End Date: \(self.semi2End!)")
        
        // Subtract five months from semi2End and set the day to the 1st
        components = DateComponents()
        components.month = -5
        guard let startOfFiveMonthsPrior = calendar.date(byAdding: components, to: self.semi2End!) else {
            print("Failed to compute start of five months prior")
            return
        }
        
        guard let firstDayOfFiveMonthsPrior = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfFiveMonthsPrior)) else {
            print("Failed to set day to 1 of five months prior")
            return
        }
        
        self.semi2Start = firstDayOfFiveMonthsPrior
        print("Semi2 Start Date: \(self.semi2Start!)")
        
        // Subtract one day from semi2Start to set semi1End
        guard let semi1EndDate = calendar.date(byAdding: .day, value: -1, to: self.semi2Start!) else {
            print("Failed to compute semi1End")
            return
        }
        self.semi1End = semi1EndDate
        print("Semi1 End Date: \(self.semi1End!)")
        
        // Subtract five months from semi1End and set the day to 1
        components.month = -5
        components.day = 1 - calendar.component(.day, from: semi1EndDate)
        guard let semi1StartDate = calendar.date(byAdding: components, to: semi1EndDate) else {
            print("Failed to compute semi1Start")
            return
        }
        
        self.semi1Start = semi1StartDate
        print("Semi1 Start Date: \(self.semi1Start!)")
    }
    
    private func filterItemsByAllowedAircraft(_ items: [FlightLogItem]) -> [FlightLogItem] {
        let filteredItems = items.filter { aircraft.contains($0.acft) }
        print("Items filtered by allowed aircraft:")
        print(filteredItems)
        return filteredItems
    }
    
    private func filterItemsBySim(_ items: [FlightLogItem]) -> [FlightLogItem] {
        let filteredItems = items.filter { !aircraft.contains($0.acft) }
        print("Items filtered by simulation:")
        print(filteredItems)
        return filteredItems
    }
    //update DBFunctions go here add comments field to each map in the array logs then saves over document and loops over every document in the collection flightlog for the user
    //also now sets all !AH-64 || !SIM aircraft seat to ""
    private func addCommentsFieldToFlightLogs(completion: @escaping () -> Void) {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated or UID not available.")
            completion() // Call completion even if the operation fails
            return
        }
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion() // Call completion even if the operation fails
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                print("No documents found.")
                completion() // Call completion even if there are no documents
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in querySnapshot.documents {
                dispatchGroup.enter()
                let documentRef = document.reference
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let documentSnapshot: DocumentSnapshot
                    do {
                        documentSnapshot = try transaction.getDocument(documentRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        print("Error fetching document: \(fetchError.localizedDescription)")
                        return nil
                    }
                    
                    guard var logs = documentSnapshot.data()?["logs"] as? [[String: Any]] else {
                        print("No 'logs' array found in document \(document.documentID).")
                        return nil
                    }
                    
                    logs = logs.map { log in
                        var mutableLog = log
                        
                        // Ensure 'comments' field is set to an empty string if it doesn't exist
                        if mutableLog["comments"] == nil {
                            mutableLog["comments"] = ""
                        }
                        
                        // Set 'seat' to an empty string if 'aircraft' is not "AH-64E" or "AH-64D"
                        if let aircraft = mutableLog["acft"] as? String, !(aircraft == "AH-64E" || aircraft == "AH-64D" || aircraft == "SIM") {
                            mutableLog["seat"] = ""
                        }
                        
                        return mutableLog
                    }
                    
                    transaction.updateData(["logs": logs], forDocument: documentRef)
                    return nil
                }) { _, error in
                    if let error = error {
                        print("Error updating document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("Document \(document.documentID) updated successfully.")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Update the DBversion and print to verify
                SettingsManager.shared.DBversion = 3
                print("DBversion updated to \(SettingsManager.shared.DBversion)")
                completion() // Notify completion of the update process
            }
        }
        print(SettingsManager.shared.DBversion)
    }

}

