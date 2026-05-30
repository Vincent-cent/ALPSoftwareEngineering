//
//  RegisterView.swift
//  shannonfinaltestSEfix
//
//  Halaman registrasi akun
//

import SwiftUI

struct RegisterView: View {
    var isAdminMode: Bool = false
    
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
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: isAdminMode ? "person.badge.key" : "person.badge.plus")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(isAdminMode ? "Buat Akun Pegawai/Warga" : "Daftar Akun Baru")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if !isAdminMode {
                                Text("Semua pengguna baru akan terdaftar sebagai Warga (Resident)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            
                            if isAdminMode {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Pilih Hak Akses (Role)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
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
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Nama Lengkap")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "person").foregroundColor(.gray)
                                    TextField("Masukkan nama", text: $name)
                                }
                                .padding().background(Color(.systemBackground)).cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "envelope").foregroundColor(.gray)
                                    TextField("Masukkan email", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding().background(Color(.systemBackground)).cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "lock").foregroundColor(.gray)
                                    SecureField("Min. 6 karakter", text: $password)
                                }
                                .padding().background(Color(.systemBackground)).cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Konfirmasi Password")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "lock.shield").foregroundColor(.gray)
                                    SecureField("Ulangi password", text: $confirmPassword)
                                }
                                .padding().background(Color(.systemBackground)).cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: registerAction) {
                            HStack {
                                if authController.isLoading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).padding(.trailing, 8)
                                }
                                Text(authController.isLoading ? "Memproses..." : (isAdminMode ? "Buat Akun Sekarang" : "Daftar Sekarang"))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty || email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(name.isEmpty || email.isEmpty || password.isEmpty || authController.isLoading)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        if !isAdminMode {
                            Button("Sudah punya akun? Login di sini") { dismiss() }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.bottom, 30)
                        } else {
                            Spacer(minLength: 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(isAdminMode ? "Tutup" : "Batal") { dismiss() })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Berhasil" : "Peringatan"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess { dismiss() }
                    }
                )
            }
        }
    }
    
    private func registerAction() {
        if password != confirmPassword {
            alertMessage = "Konfirmasi password tidak cocok"
            showAlert = true; return
        }
        if password.count < 6 {
            alertMessage = "Password minimal harus 6 karakter"
            showAlert = true; return
        }
        
        authController.registerEmail(username: name, email: email, password: password, role: selectedRole)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let error = authController.errorMessage {
                alertMessage = error
                isSuccess = false
                showAlert = true
            } else {
                alertMessage = isAdminMode ? "Akun \(selectedRole) berhasil dibuat!" : "Pendaftaran berhasil! Akun Anda terdaftar sebagai Warga."
                isSuccess = true
                showAlert = true
            }
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
            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color.blue.opacity(0.08) : Color.clear))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthController())
}
