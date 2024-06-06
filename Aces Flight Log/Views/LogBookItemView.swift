import SwiftUI

struct LogBookItemView: View {
    let flightlogitemview: FlightLogItem
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Text("Date")
                    .font(.caption)
                Text("\(formattedDate(from: flightlogitemview.dof))")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("ACFT")
                    .font(.caption)
                Text("\(flightlogitemview.acft)")
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("DUTY")
                    .font(.caption)
                Text("\(flightlogitemview.duty)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("COND")
                    .font(.caption)
                Text("\(flightlogitemview.condition)")
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            if flightlogitemview.acft == "AH-64D" || flightlogitemview.acft == "AH-64E" {
                VStack {
                    Text("SEAT")
                        .font(.caption)
                    Text("\(flightlogitemview.seat)")
                        .font(.headline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }

            VStack {
                Text("HRS")
                    .font(.caption)
                Text("\(String(format: "%.1f", flightlogitemview.hours))")
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
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct LogBookItemView_Previews: PreviewProvider {
    static var previews: some View {
        LogBookItemView(flightlogitemview: FlightLogItem(id: "hello", dof: Date().timeIntervalSince1970, acft: "UH-60L", duty: "PI", condition: "N", seat: "F", hours: 1.2, createdDate: Date().timeIntervalSince1970))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
