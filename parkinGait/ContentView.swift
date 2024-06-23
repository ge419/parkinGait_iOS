//
//  ContentView.swift
//  parkinGait
//
//  Created by 신창민 on 6/22/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("git test")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
