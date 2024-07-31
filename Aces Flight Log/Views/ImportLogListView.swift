import SwiftUI

struct ImportLogListView: View {
    @StateObject private var viewModel = ImportLogListViewModel()
    @State private var itemsToDelete = Set<Int>()
    @State private var showFormatInstructions = true // State variable to control HStack visibility
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Text("IMPORT LOGBOOK")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                if showFormatInstructions {
                    Text("Please make sure your CSV follows this format")
                    Text("and the date format is dd-mmm-yyyy")
                    HStack {
                        VStack {
                            Text("A")
                            Text("Acft")
                        }
                        VStack {
                            Text("B")
                            Text("Date")
                        }
                        VStack {
                            Text("C")
                            Text("Duty")
                        }
                        VStack {
                            Text("D")
                            Text("Condition")
                        }
                        VStack {
                            Text("E")
                            Text("Seat")
                        }
                        VStack {
                            Text("F")
                            Text("Hours")
                        }
                    }
                }
                VStack {
                    List {
                        ForEach(viewModel.importLogItems.indices, id: \.self) { index in
                            ImportLogItemView(importLogItem: viewModel.importLogItems[index])
                        }
                        .onDelete(perform: deleteItems)
                    }
                    
                    Button(action: {
                        viewModel.saveImportLogItems()
                        self.presentationMode.wrappedValue.dismiss() // Navigate back to the main view
                    }) {
                        Text("SAVE LOGBOOK")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationBarItems(
                    trailing: Button(action: {
                        viewModel.pickCSVFile()
                        showFormatInstructions = false // Hide the HStack when import button is pressed
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                )
            }
        } else {
            // Fallback on earlier versions
            if showFormatInstructions {
                        Text("Import Log List")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.red)
                            .padding()
                        Text("Please make sure your CSV follows this format")
                        HStack {
                            VStack {
                                Text("A")
                                Text("Acft")
                            }
                            VStack {
                                Text("B")
                                Text("Date")
                            }
                            VStack {
                                Text("C")
                                Text("Duty")
                            }
                            VStack {
                                Text("D")
                                Text("Condition")
                            }
                            VStack {
                                Text("E")
                                Text("Seat")
                            }
                            VStack {
                                Text("F")
                                Text("Hours")
                            }
                        }
                Button("Select File") {
                    viewModel.pickCSVFileiOS15()
                    showFormatInstructions = false
                }
                    }
                    VStack {
                        List {
                            ForEach(viewModel.importLogItems.indices, id: \.self) { index in
                                ImportLogItemView(importLogItem: viewModel.importLogItems[index])
                            }
                            .onDelete(perform: deleteItems)
                        }
                        
                        Button(action: {
                            viewModel.saveImportLogItems()
                            self.presentationMode.wrappedValue.dismiss() // Navigate back to the main view
                        }) {
                            Text("SAVE LOGBOOK")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
    private func deleteItems(at offsets: IndexSet) {
        // Implement item deletion logic here
    }
}

struct ImportLogListView_Previews: PreviewProvider {
    static var previews: some View {
        ImportLogListView()
    }
}
