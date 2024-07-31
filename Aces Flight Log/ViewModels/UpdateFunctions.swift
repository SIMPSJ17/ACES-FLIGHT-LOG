import Firebase
import FirebaseFirestore

class Updates: ObservableObject {
    func addCommentsFieldToFlightLogs() {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated or UID not available.")
            return
        }
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                print("No documents found.")
                return
            }
            
            for document in querySnapshot.documents {
                let documentRef = document.reference
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let documentSnapshot: DocumentSnapshot
                    do {
                        documentSnapshot = try transaction.getDocument(documentRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard var logs = documentSnapshot.data()?["logs"] as? [[String: Any]] else {
                        print("No 'logs' array found in document \(document.documentID).")
                        return nil
                    }
                    
                    // Update each log entry to include comments if it doesn't exist
                    logs = logs.map { log in
                        var mutableLog = log
                        if mutableLog["comments"] == nil {
                            mutableLog["comments"] = ""
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
                }
            }
        }
    }
}
