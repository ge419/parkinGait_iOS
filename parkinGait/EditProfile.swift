//
//  EditProfile.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI

struct EditProfile: View {
    @State private var name: String = ""
    @State private var height: String = ""
    let appearance = UINavigationBarAppearance()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Name")
                .font(.body)
            TextField("Name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            Text("Height")
            TextField("Height", text: $height)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            // Save Changes button
//            Button(action: <#T##() -> Void#>, label: <#T##() -> Label#>)
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Profile")
    }
}

#Preview {
    EditProfile()
}
