//
//  Login.swift
//  parkinGait
//
//  Created by 신창민 on 6/22/24.
//

import SwiftUI
import FirebaseAuth


struct Login: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    let bgColor = Color(red: 0.8706, green: 0.8549, blue: 0.8235)

    
    var body: some View {
            NavigationStack{
                ZStack{
                bgColor.ignoresSafeArea()
                VStack{
                    VStack {
                        Image("icon")
                            .resizable()
                            .frame(width: 110, height: 110)
                            .padding(.bottom, 20)
                    }
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button {
                            Task {
                                try await viewModel.signIn(withEmail: email,password: password)
                            }
                        } label: {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }.disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0: 0.5)
                    
                        NavigationLink(destination: Register(), label: {
                            Text("Create New User")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2))
                        })
                        
                        NavigationLink(destination: ForgotPassword(), label: {
                            Text("Forgot Your Password?")
                                .frame(alignment: .center)
                                .foregroundColor(.blue)
                        })
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
}

extension Login: AuthenticationFormProtocol {
    var formIsValid: Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: [.caseInsensitive])
        return !email.isEmpty
        &&
        regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
        && !password.isEmpty
    }
}

#Preview {
    Login()
}
