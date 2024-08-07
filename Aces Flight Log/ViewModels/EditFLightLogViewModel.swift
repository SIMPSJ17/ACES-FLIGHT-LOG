import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class EditFlightLogViewModel: ObservableObject {
    
    @Published var id: String
    @Published var dof: Date
    @Published var acft: String
    @Published var duty: String
    @Published var condition: String
    @Published var seat: String
    @Published var hours: Double
    @Published var comments: String
    @Published var showAlert: Bool = false
    @Published var createdDate: TimeInterval
    @State var firestoreQuery: Firestorequery
    @State var pickermodel = pickerlist()

    init(item: FlightLogItem, firestoreQuery: Firestorequery) {
        self.id = item.id
        self.dof = Date(timeIntervalSince1970: item.dof)
        self.acft = item.acft
        self.duty = item.duty
        self.condition = item.condition
        self.seat = item.seat
        self.hours = item.hours
        self.createdDate = item.createdDate
        self.comments = item.comments
        self.firestoreQuery = firestoreQuery
        print("EditFlightLogViewModel initialized with id: \(self.id)")
        print("Date of Flight: \(self.dof)")
        print("Aircraft: \(self.acft)")
        print("Duty: \(self.duty)")
        print("Condition: \(self.condition)")
        print("Seat: \(self.seat)")
        print("Hours: \(self.hours)")
        print("Comments: \(self.comments)")
    }

    var canSave: Bool {
        // Add validation logic here
        return !acft.isEmpty && !duty.isEmpty && !condition.isEmpty && hours > 0
    }

    func update() {
        guard canSave else {
            showAlert = true
            return
        }

        // Get the current user's UID
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        // Step 1: Fetch the document
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                self.showAlert = true
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found.")
                self.showAlert = true
                return
            }
            
            // Step 2: Find the specific map with the given id
            for document in documents {
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
                    
                    // Step 3: Update the specific log entry
                    if let index = logs.firstIndex(where: { $0["id"] as? String == self.id }) {
                        var logEntry = logs[index]
                        logEntry["dof"] = self.dof.timeIntervalSince1970
                        logEntry["acft"] = self.acft
                        logEntry["duty"] = self.duty
                        logEntry["condition"] = self.condition
                        logEntry["seat"] = self.seat
                        logEntry["hours"] = self.hours
                        logEntry["comments"] = self.comments
                        
                        logs[index] = logEntry
                        transaction.updateData(["logs": logs], forDocument: documentRef)
                    }
                    
                    return nil
                }) { _, error in
                    if let error = error {
                        print("Error updating document \(document.documentID): \(error.localizedDescription)")
                        self.showAlert = true
                    } else {
                        print("Document \(document.documentID) updated successfully.")
                    }
                }
            }
        }
    }
}
