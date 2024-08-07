import FirebaseAuth
import FirebaseFirestore
import MobileCoreServices // Required for file types

class ImportLogListViewModel: NSObject, ObservableObject {
    @Published var isDocumentPickerPresented = false
    @Published var importLogItems: [ImportLogItem] = []

    func parseCSV(fileURL: URL) throws -> [ImportLogItem] {
        var items = [ImportLogItem]()
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = contents.components(separatedBy: "\n")
        var isFirstLine = true
        let comments = ""
        
        for row in rows {
            if isFirstLine {
                isFirstLine = false
                continue
            }
            
            let columns = row.split(separator: ",").map { String($0) }
            if columns.count == 7 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                
                let item = ImportLogItem(
                    id: UUID().uuidString,
                    dof: dateFormatter.date(from: columns[1])?.timeIntervalSince1970 ?? 0,
                    acft: columns[0],
                    duty: columns[2],
                    condition: columns[3],
                    seat: columns[4],
                    hours: Double(columns[5]) ?? 0,
                    createdDate: Date().timeIntervalSince1970,
                    comments: comments
                )
                items.append(item)
            }
        }
        return items.sorted(by: { $0.dof < $1.dof })
    }
    
    func pickCSVFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func pickCSVFileiOS15() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            var presentingViewController = rootViewController
            while let presentedViewController = presentingViewController.presentedViewController {
                presentingViewController = presentedViewController
            }
            
            presentingViewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    func saveImportLogItems() {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        let logsCollectionRef = db.collection("users").document(uId).collection("FlightLog")
        
        logsCollectionRef.whereField("entryCount", isLessThan: 1500).limit(to: 1).getDocuments { [self] snapshot, error in
            if let error = error {
                print("Error retrieving documents: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot?.documents.first {
                let documentRef = document.reference
                
                var entryCount = 0
                var currentLogs = document.data()["logs"] as? [[String: Any]] ?? []
                entryCount = document.data()["entryCount"] as? Int ?? 0
                
                for item in self.importLogItems {
                    if entryCount < 1500 {
                        // Determine the seat value based on the aircraft type
                        let seatPosition: String
                        if item.acft == "AH-64E" || item.acft == "AH-64D" {
                            seatPosition = item.seat
                        } else {
                            seatPosition = ""
                        }
                        
                        let newLog = [
                            "id": UUID().uuidString, // Generate a unique ID for each log item
                            "dof": item.dof,
                            "acft": item.acft,
                            "duty": item.duty,
                            "condition": item.condition,
                            "seat": seatPosition, // Use the determined seat position
                            "hours": item.hours,
                            "createdDate": item.createdDate,
                            "comments": "" // Always set comments to an empty string
                        ] as [String : Any]
                        
                        currentLogs.append(newLog)
                        entryCount += 1
                    }
                }
                
                documentRef.updateData([
                    "logs": currentLogs,
                    "entryCount": entryCount
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Logs added to existing document.")
                    }
                }
            } else {
                let newDocumentRef = logsCollectionRef.document()
                var logs = [[String: Any]]()
                
                for item in importLogItems {
                    // Determine the seat value based on the aircraft type
                    let seatPosition: String
                    if item.acft == "AH-64E" || item.acft == "AH-64D" {
                        seatPosition = item.seat
                    } else {
                        seatPosition = ""
                    }
                    
                    let newLog = [
                        "id": UUID().uuidString, // Generate a unique ID for each log item
                        "dof": item.dof,
                        "acft": item.acft,
                        "duty": item.duty,
                        "condition": item.condition,
                        "seat": seatPosition, // Use the determined seat position
                        "hours": item.hours,
                        "createdDate": item.createdDate,
                        "comments": "" // Always set comments to an empty string
                    ] as [String : Any]
                    
                    logs.append(newLog)
                }
                
                let initialData = [
                    "logs": logs,
                    "entryCount": self.importLogItems.count
                ] as [String : Any]
                
                newDocumentRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating new document: \(error.localizedDescription)")
                    } else {
                        print("New document created with logs.")
                    }
                }
            }
        }
    }
}

extension ImportLogListViewModel: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }

        if fileURL.startAccessingSecurityScopedResource() {
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }

            do {
                importLogItems = try parseCSV(fileURL: fileURL)
                print("CSV file imported successfully.")
            } catch {
                print("Error importing CSV file: \(error.localizedDescription)")
            }
        } else {
            print("Error: Failed to start accessing security-scoped resource.")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
