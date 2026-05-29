//
//  AuthController.swift
//  shannonfinaltestSEfix
//
//  Controller untuk autentikasi user
//

// ini masih pakai dummy data
// nanti bisa diubah buat hub ke backend pakai firebase
import Foundation
import SwiftUI
import Combine

class AuthController: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Database simulasi
    private var users: [UserModel] = []
    
    init() {
        loadSampleUsers()
    }
    
    private func loadSampleUsers() {
        users = [
            UserModel(id: "001", name: "Admin Aqua", email: "admin@aqua.com", role: "admin"),
            UserModel(id: "002", name: "Budi Santoso", email: "budi@mail.com", role: "resident"),
            UserModel(id: "003", name: "Teknisi Jaya", email: "teknisi@aqua.com", role: "technician"),
            UserModel(id: "004", name: "Siti Aminah", email: "siti@mail.com", role: "community_leader")
        ]
    }
    
    func register(name: String, email: String, password: String, role: String) -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simulasi delay network
        Thread.sleep(forTimeInterval: 0.5)
        
        // Cek email sudah terdaftar
        if users.contains(where: { $0.email == email }) {
            errorMessage = "Email sudah terdaftar"
            isLoading = false
            return false
        }
        
        // Validasi password
        if password.count < 6 {
            errorMessage = "Password minimal 6 karakter"
            isLoading = false
            return false
        }
        
        // Buat user baru
        let newUser = UserModel(
            id: UUID().uuidString,
            name: name,
            email: email,
            role: role
        )
        users.append(newUser)
        currentUser = newUser
        isLoggedIn = true
        isLoading = false
        return true
    }
    
    func login(email: String, password: String) -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simulasi delay network
        Thread.sleep(forTimeInterval: 0.5)
        
        // Validasi input
        if email.isEmpty {
            errorMessage = "Email harus diisi"
            isLoading = false
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password harus diisi"
            isLoading = false
            return false
        }
        
        // Cari user berdasarkan email
        if let user = users.first(where: { $0.email == email }) {
            currentUser = user
            isLoggedIn = true
            isLoading = false
            return true
        }
        
        // Demo: auto create user untuk email baru
        let newUser = UserModel(
            id: UUID().uuidString,
            name: email.components(separatedBy: "@").first?.capitalized ?? "User",
            email: email,
            role: "resident"
        )
        users.append(newUser)
        currentUser = newUser
        isLoggedIn = true
        isLoading = false
        return true
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        errorMessage = nil
    }
}
