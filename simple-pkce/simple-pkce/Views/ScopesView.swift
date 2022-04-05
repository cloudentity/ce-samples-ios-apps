//
//  ClaimsView.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

import SwiftUI

struct ScopesView: View {
    @State private var alertVisible = false
    @State private var selectScope:String = ""
    let scopes: [String]?
    
    init(scopes: String?) {
        self.scopes = scopes?.components(separatedBy: " ")
    }
    
    var body: some View {
        VStack {
            if scopes == nil {
                Text("Error getting scopes from JWT!")
            } else {
                ForEach(scopes!, id: \.self) { scope in
                    Button(scope) {
                        selectScope = scope
                        alertVisible = true
                    }
                    .padding(.bottom, 10)
                    .alert("'\(selectScope)' scope enabled me", isPresented: $alertVisible) {
                        Button("Close", role: .cancel) { }
                    }
                }
                Spacer()
            }
        }
    }
}

struct ScopesView_Previews: PreviewProvider {
    static var previews: some View {
        ScopesView(scopes: "profile email")
    }
}
