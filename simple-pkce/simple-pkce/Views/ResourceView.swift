//
//  ResourceView.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/6/22.
//

import SwiftUI

struct ResourceView: View {
    @ObservedObject var resource: Remote<String>
    
    init(_ url: URL) {
        resource = Remote(url: url, transform: { $0.prettyJson })
        resource.load()
    }

    var body: some View {
        VStack {
            if resource.value == nil {
                Text("Fetching resource...").font(.title)
                ProgressView()
            } else {
                Text("Response").font(.title)
                Text(resource.value!)
            }
        }
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(URL(string: "https://gorest.co.in/public/v2/users/2906")!)
    }
}
