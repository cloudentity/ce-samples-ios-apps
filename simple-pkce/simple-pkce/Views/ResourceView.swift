//
//  ResourceView.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/6/22.
//

import SwiftUI

struct ResourceView: View {
    @ObservedObject var resource: Remote<String>
    
    init(_ url: URL, token: String?) {
        resource = Remote(token: token,url: url, transform: { $0.prettyJson })
        resource.load()
    }

    var body: some View {
        VStack {
            Spacer()
            switch resource.result {
            case .success(let resp):
                Text("Response").font(.title)
                Text(resp)
            case .failure(let err):
                Text(err.localizedDescription)
            default:
                Text("Fetching resource...").font(.title)
                ProgressView()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(URL(string: "https://gorest.co.in/public/v2/users/2906")!, token: "abc123")
    }
}
