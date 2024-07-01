//
//  ContentView.swift
//  parkinGait
//
//  Created by 신창민 on 6/22/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainPage()
            } else {
                Login()
            }
        }
    }
}

#Preview {
    ContentView()
}
