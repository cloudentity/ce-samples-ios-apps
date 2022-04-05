//
//  LoginView.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authentication: Authentication
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            if loginViewModel.showProgress {
                ProgressView()
            }
            Image("Black").resizable().scaledToFit().frame(width: 250).padding()
            HStack {
                Image(systemName: "person.circle")
                    .font(.title)
                Button("Sign In") {
                    loginViewModel.login { res, err in
                        authentication.updateAuthenticated(res: res, err: err)
                    }
                }
            }
            .frame(width: 160, height: 20, alignment: .center)
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(30)
            if authentication.err != nil {
                Text(authentication.err!.localizedDescription).foregroundColor(.red).padding()
            }
        }
        .disabled(loginViewModel.showProgress)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
