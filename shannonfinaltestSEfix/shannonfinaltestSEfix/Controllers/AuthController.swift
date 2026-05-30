//
//  AuthController.swift
//  shannonfinaltestSEfix
//
//  Controller untuk autentikasi user
//

// ini masih pakai dummy data
// nanti bisa diubah buat hub ke backend pakai firebase
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthController: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        if let firebaseUser = Auth.auth().currentUser {
            self.isLoading = true
            fetchUserData(uid: firebaseUser.uid)
        } else {
            self.isLoggedIn = false
        }
    }
    
    func registerEmail(username: String, email: String, password: String, role: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            let userData: [String: Any] = [
                "id": uid,
                "name": username,
                "email": email,
                "role": role
            ]
            
            self.db.collection("users").document(uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.currentUser = UserModel(id: uid, name: username, email: email, role: role)
                        self.isLoggedIn = true
                    }
                }
            }
        }
    }
    
    func loginEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            self.fetchUserData(uid: uid)
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isLoggedIn = false
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { document, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let document = document, document.exists, let data = document.data() {
                    let id = data["id"] as? String ?? uid
                    let name = data["name"] as? String ?? "User"
                    let email = data["email"] as? String ?? ""
                    let role = data["role"] as? String ?? "resident"
                    
                    self.currentUser = UserModel(id: id, name: name, email: email, role: role)
                    self.isLoggedIn = true
                    self.errorMessage = nil
                } else {
                    try? Auth.auth().signOut()
                    self.currentUser = nil
                    self.isLoggedIn = false
                    self.errorMessage = "Sesi telah berakhir atau profil tidak ditemukan. Silakan login kembali."
                }
            }
        }
    }
}
