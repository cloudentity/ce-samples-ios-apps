import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: Store
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            if loginViewModel.showProgress {
                ProgressView()
            }
            Image("Black").resizable().scaledToFit().frame(width: 250).padding()
            HStack {
                Image(systemName: "person.circle")
                    .font(.title)
                Button("Sign In") {
                    loginViewModel.login { res, err in
                        store.updateAuthenticated(res: res, err: err)
                    }
                }
            }
            .frame(width: 160, height: 20, alignment: .center)
            .padding()
            .foregroundColor(.white)
            .background(AppTheme.buttonColor)
            .cornerRadius(30)
            if store.err != nil {
                Text(store.err!.localizedDescription).foregroundColor(.red).padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .background(AppTheme.backgroundColor)
        .disabled(loginViewModel.showProgress)
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
    
