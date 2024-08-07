import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LogbookView: View {
    @ObservedObject var firestoreQuery: Firestorequery
    @State private var showingFlightLogView = false
    @State private var selectedFlightLogItem: FlightLogItem?
    @State private var showingEditFlightLogView = false
    
    init(userId: String) {
        self.firestoreQuery = Firestorequery(userId: userId)
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("LOGBOOK")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                
                List(firestoreQuery.items) { item in
                    LogBookItemView(flightlogitemview: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                firestoreQuery.delete(id: item.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button(action: {
                                selectedFlightLogItem = item
                                showingEditFlightLogView = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
                .listStyle(PlainListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFlightLogView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(
                        destination: ImportLogListView(),
                        label: {
                            Text("Import -12")
                        })
                }
            }
            .sheet(item: $selectedFlightLogItem) { item in
                EditFlightLogView(viewModel: EditFlightLogViewModel(item: item, firestoreQuery: firestoreQuery))
                    .onDisappear {
                        // Reset selectedFlightLogItem when sheet disappears
                        selectedFlightLogItem = nil
                    }
            }
            .sheet(isPresented: $showingFlightLogView) {
                LogFlightView(viewmodel: LogFlightViewModel())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
