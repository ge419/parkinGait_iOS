//
//  Register.swift
//  parkinGait
//
//  Created by 신창민 on 6/22/24.
//

import SwiftUI

struct Register: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var height = ""
    
    let bgColor = Color(red: 0.8706, green: 0.8549, blue: 0.8235)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack {
                Text("Registration")
                    .font(.largeTitle)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                TextField("Height (inches)", text: $height)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                }
                .padding()
                Spacer()
            }
            
        }
    }
}

#Preview {
    Register()
}
