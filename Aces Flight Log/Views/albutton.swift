import SwiftUI

struct albutton: View {
    
    let title: String
    let bgroundcolor: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()}
    label: {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(bgroundcolor)
            Text(title)
                .foregroundColor(.white)
                .bold()
        }
    }
    }
}
#Preview {
    albutton(title: "hello", bgroundcolor: .red) {//action
    }
}
