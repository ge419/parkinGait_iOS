//
//  ForgotPassword.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI

struct ForgotPassword: View {
    
    @State private var email: String = ""
    @State private var isValidEmail: Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let bgColor = Color(red: 0.8706, green: 0.8549, blue: 0.8235)
    
    var body: some View {
        ZStack{
            bgColor.ignoresSafeArea()
            VStack(spacing: 10) {
                Text("Forgot Password?")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                
                Text("To reset your password, enter your email again and a link to reset your password will be sent.")
                    .padding()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                //            Button(action: handleResetPassword) {
                //                Text("Reset Password")
                //                    .fontWeight(.bold)
                //                    .frame(maxWidth: .infinity)
                //                    .padding()
                //                    .background(Color.green)
                //                    .foregroundColor(.white)
                //                    .cornerRadius(8)
                //            }
                Spacer()
            }.padding()
        }
    }
}

#Preview {
    ForgotPassword()
}
