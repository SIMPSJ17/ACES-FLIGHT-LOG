import SwiftUI

struct LogbookView: View {
    @ObservedObject var firestoreQuery: Firestorequery
    @State private var showingFlightLogView = false
    @State private var showingImportLogBookView = false
    
    init(userId: String) {
        self.firestoreQuery = Firestorequery(userId: userId)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("LOGBOOK")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                
                List(firestoreQuery.items) { item in
                    LogBookItemView(flightlogitemview: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                // Removed reference to unused index
                                firestoreQuery.delete(id: item.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
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
            .sheet(isPresented: $showingFlightLogView) {
                LogFlightView(viewmodel: LogFlightViewModel())
            }
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView(userId: "Xvsr8jFbxbglwDdCyI8ifgEOKgx2")
    }
}
