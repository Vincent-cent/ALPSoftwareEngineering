//
//  RegisterView.swift
//  shannonfinaltestSEfix
//
//  Halaman registrasi akun
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole = "resident"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    let roles = [
        ("resident", "Warga", "person.fill"),
        ("community_leader", "Ketua RT/RW", "person.3.fill"),
        ("admin", "Admin", "shield.fill"),
        ("technician", "Teknisi", "wrench.fill")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
               
                Color(.systemGray6).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 35))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Buat Akun Baru")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Laporkan masalah air & sanitasi")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nama Lengkap")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    TextField("Masukkan nama lengkap", text: $name)
                                        .textInputAutocapitalization(.words)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .background(
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    TextField("email@example.com", text: $email)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .background(
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    SecureField("Minimal 6 karakter", text: $password)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .background(
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                            }
                            
                            // Konfirmasi Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Konfirmasi Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    SecureField("Ketik ulang password", text: $confirmPassword)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .background(
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Role Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pilih Role")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(roles, id: \.0) { role in
                                        RoleCard(
                                            roleName: role.1,
                                            roleIcon: role.2,
                                            isSelected: selectedRole == role.0
                                        ) {
                                            selectedRole = role.0
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                
                        PrimaryButton(
                            title: "Daftar",
                            icon: "checkmark",
                            isLoading: authController.isLoading
                        ) {
                            register()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Daftar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("Info", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func register() {
        // Validasi
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Nama lengkap harus diisi"
            showAlert = true
            return
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Email harus diisi"
            showAlert = true
            return
        }
        
        if !email.contains("@") || !email.contains(".") {
            alertMessage = "Email tidak valid"
            showAlert = true
            return
        }
        
        if password.count < 6 {
            alertMessage = "Password minimal 6 karakter"
            showAlert = true
            return
        }
        
        if password != confirmPassword {
            alertMessage = "Password tidak cocok"
            showAlert = true
            return
        }
        
        let success = authController.register(
            name: name,
            email: email,
            password: password,
            role: selectedRole
        )
        
        if success {
            alertMessage = "Pendaftaran berhasil!\nSelamat datang, \(name)"
            isSuccess = true
            showAlert = true
            isLoggedIn = true
        } else {
            alertMessage = authController.errorMessage ?? "Pendaftaran gagal"
            showAlert = true
        }
    }
}


struct RoleCard: View {
    let roleName: String
    let roleIcon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: roleIcon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(roleName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthController())
}
