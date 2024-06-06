import SwiftUI

struct ImportLogListView: View {
    var importLogItems: [FlightLogItem]
    @State private var itemsToDelete = Set<Int>()
    
    var body: some View {
        List {
            ForEach(importLogItems.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text("ID: \(importLogItems[index].id)")
                    Text("Date: \(importLogItems[index].dof)")
                    Text("Aircraft: \(importLogItems[index].acft)")
                    Text("Duty: \(importLogItems[index].duty)")
                    Text("Condition: \(importLogItems[index].condition)")
                    Text("Hours: \(importLogItems[index].hours)")
                }
                .padding()
                .background(self.itemsToDelete.contains(index) ? Color.red.opacity(0.3) : Color.clear)
                .onTapGesture {
                    if self.itemsToDelete.isEmpty {
                        // Handle tapping when not in delete mode
                    } else {
                        // Toggle item selection for deletion
                        if self.itemsToDelete.contains(index) {
                            self.itemsToDelete.remove(index)
                        } else {
                            self.itemsToDelete.insert(index)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        // Delete selected items
        // Since flightLogItems is not a State property, we can't mutate it directly.
        // We need a reference to the source of truth to mutate it.
        // You need to update the source of truth from the parent view
        // and then pass the updated flightLogItems back to this view.
    }
}

struct importLogListView_Previews: PreviewProvider {
    static var previews: some View {
        let testItems = [
            importLogItem(id: "1", dof: 1619377200, acft: "Test Aircraft 1", duty: "Test Duty 1", condition: "Test Condition 1", hours: 5.0, createdDate: 1619377200),
            importLogItem(id: "2", dof: 1619378200, acft: "Test Aircraft 2", duty: "Test Duty 2", condition: "Test Condition 2", hours: 7.0, createdDate: 1619378200)
        ]
        return FlightLogListView(flightLogItems: testItems)
    }
}
