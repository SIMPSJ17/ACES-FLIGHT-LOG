import SwiftUI

struct Headerview: View {
    let title: String
    let subtitle: String
    let angle: Double
    let backgroundcolor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(backgroundcolor)
                    .frame(height: geometry.size.height * 1.5) // Expand beyond screen height
                    .rotationEffect(.degrees(angle))
                
                VStack {
                    Text(title)
                        .font(.system(size: geometry.size.width * 0.15)) // Scale font size based on width
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: geometry.size.width * 0.08)) // Scale font size based on width
                        .foregroundColor(.black)

                }
            }
            .frame(width: geometry.size.width) // Match parent width
        }
    }
}

struct Headerview_Previews: PreviewProvider {
    static var previews: some View {
        Headerview(title: "ACES LOG",
                   subtitle: "YOU BOYS LIKE MEXICO",
                   angle: 100,
                   backgroundcolor: .red)
    }
}
