//
//  AuthViewModel.swift
//  parkinGait
//
//  Created by 신창민 on 7/1/24.
//

import Firebase
import Foundation

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("Sign in...")
    }
    
    func createUser(withEmail email: String, password: String, name: String, height: String) async throws {
        print("Create User...")
    }
    
    func signOut() {
        
    }
    
    func fetchUser() async {
        
    }
    
}


//struct AuthViewModel: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    AuthViewModel()
//}
