import SwiftUI

struct TokenSegmentView: View {
    var data: String?
    
    init(data: String?) {
        self.data = data
    }
    
    var body: some View {
        VStack {
            if data == nil {
                Text("Error parsing JWT!")
            } else {
                ScrollView {
                    Text(data!).padding().font(.system(size: 12))
                }.cornerRadius(30)
            }
            
        }.foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(AppTheme.backgroundColor)
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenSegmentView(data: "abc123")
    }
}
