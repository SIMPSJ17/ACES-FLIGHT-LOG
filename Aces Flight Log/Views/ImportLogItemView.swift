import SwiftUI

struct ImportLogItemView: View {
    let importLogItem: ImportLogItem
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Text("Date")
                    .font(.caption)
                Text("\(formattedDate(from: importLogItem.dof))")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("ACFT")
                    .font(.caption)
                Text("\(importLogItem.acft)")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("DUTY")
                    .font(.caption)
                Text("\(importLogItem.duty)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("COND")
                    .font(.caption)
                Text("\(importLogItem.condition)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            if importLogItem.acft == "AH-64" || importLogItem.acft == "AH-64E" {
                VStack {
                    Text("SEAT")
                        .font(.caption)
                    Text("\(importLogItem.seat)")
                        .font(.headline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }

            VStack {
                Text("HRS")
                    .font(.caption)
                Text("\(String(format: "%.1f", importLogItem.hours))")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Format to display only day, month, and year
        return formatter.string(from: date)
    }
}
