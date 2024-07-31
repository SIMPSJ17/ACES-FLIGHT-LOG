import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class LogFlightViewModel: ObservableObject {
    @Published var logflightacft: String = String(describing: SettingsManager.shared.aircraft ?? "UH-60M")
    @Published var logdate = Date()
    @Published var logflightduty: String = "PI"
    @Published var logflightcondition: String = "D"
    @Published var logseatposition: String = "F"
    @Published var logflighthrs: Double = 0.0
    @Published var showAlert = false
    
    init() {}
    
    var formattedHours: String {
        return String(format: "%.1f", logflighthrs)
    }
    
    func save() {
        guard canSave else {
            return
        }
        
        // Get current user id
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Prepare the new log entry as a dictionary
        let newLogEntry = FlightLogItem(
            id: UUID().uuidString,
            dof: self.logdate.timeIntervalSince1970,
            acft: self.logflightacft,
            duty: self.logflightduty,
            condition: self.logflightcondition,
            seat: self.logseatposition,
            hours: self.logflighthrs,
            createdDate: Date().timeIntervalSince1970
        ).asDictionary()
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        // Check if there is a document with space for logs
        collectionRef.whereField("entryCount", isLessThan: 1200).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            if let document = querySnapshot?.documents.first {
                let documentRef = document.reference
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let documentSnapshot: DocumentSnapshot
                    do {
                        documentSnapshot = try transaction.getDocument(documentRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    var logs = documentSnapshot.data()?["logs"] as? [[String: Any]] ?? []
                    logs.append(newLogEntry)
                    let newEntryCount = logs.count
                    
                    transaction.updateData(["logs": logs, "entryCount": newEntryCount], forDocument: documentRef)
                    return nil
                }) { _, error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Log added to existing document.")
                    }
                }
            } else {
                // No document found, need to create a new one
                let newDocumentRef = collectionRef.document()
                let initialData = ["logs": [newLogEntry], "entryCount": 1] as [String : Any]
                newDocumentRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating new document: \(error.localizedDescription)")
                    } else {
                        print("New document created with first log.")
                    }
                }
            }
        }
    }
    
    
    var canSave: Bool {
        // Check if logdate is on or before today
        guard logdate <= Date() else {
            return false
        }
        
        // Check if logflighthrs is greater than 0
        guard logflighthrs > 0 else {
            return false
        }
        
        // Check if required fields are not empty
        guard !logflightacft.isEmpty, !logflightduty.isEmpty, !logflightcondition.isEmpty else {
            return false
        }
        
        return true
    }
}
