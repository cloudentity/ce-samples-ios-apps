import SwiftUI

struct LoginView: View {
    @EnvironmentObject  var modelData: ModelData
    @State private var isLoading = false
    @State private var error: AuthError?
    
    var body: some View {
        ZStack {
            VStack {
                Image("Black")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 20)
                if isLoading {
                    ProgressView()
                } else {
                    HStack {
                        Image(systemName: "person.circle")
                        Button("Sign In") {
                            if !modelData.checkStored() {
                                isLoading.toggle()
                                Authenticator(completion: { res, err in
                                    DispatchQueue.main.async {
                                        isLoading.toggle()
                                        modelData.setToken(token: res)
                                        error = err
                                    }
                                }).authenticate()
                            }
                        }
                    }
                    .frame(width: 160, height: 20, alignment: .center)
                    .padding()
                    .foregroundColor(modelData.theme.accentColor)
                    .background(modelData.theme.mainColor)
                    .cornerRadius(30)
                    .disabled(isLoading)
                }
                
                if error != nil {
                    Text(error?.localizedDescription ?? "error signing in")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
