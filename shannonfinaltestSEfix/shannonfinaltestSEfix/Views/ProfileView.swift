//
//  ProfileView.swift
//  shannonfinaltestSEfix
//
//  Halaman profil user
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController: AuthController
    @State private var showLogoutAlert = false
    @State private var showAdminRegister = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    ProfileHeader(user: authController.currentUser)
                    
                    StatsSection()
                    
                    VStack(spacing: 12) {

                        if authController.currentUser?.role == "admin" {
                            ProfileMenuItem(
                                icon: "person.badge.plus",
                                title: "Buat Akun Pegawai",
                                subtitle: "Tambahkan Admin, Teknisi, atau RT",
                                color: .purple
                            ) {
                                showAdminRegister = true
                            }
                        }
                        
                        ProfileMenuItem(
                            icon: "doc.text.fill",
                            title: "Riwayat Laporan",
                            subtitle: "Lihat semua laporan yang pernah dibuat",
                            color: .blue
                        ) { }
                        
                        ProfileMenuItem(
                            icon: "bell.fill",
                            title: "Notifikasi",
                            subtitle: "Pengaturan notifikasi",
                            color: .orange
                        ) { }
                        
                        ProfileMenuItem(
                            icon: "info.circle.fill",
                            title: "Tentang Aplikasi",
                            subtitle: "Informasi tentang AquaAlert",
                            color: .green
                        ) { }
                        
                        ProfileMenuItem(
                            icon: "envelope.fill",
                            title: "Bantuan & Dukungan",
                            subtitle: "Hubungi tim kami",
                            color: .purple
                        ) { }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.headline)
                            Text("Logout")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Text("Versi 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .alert("Konfirmasi Logout", isPresented: $showLogoutAlert) {
                Button("Batal", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authController.logout()
                }
            } message: {
                Text("Apakah Anda yakin ingin keluar?")
            }
            .sheet(isPresented: $showAdminRegister) {
                RegisterView(isAdminMode: true)
                    .environmentObject(authController)
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let user: UserModel?
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text(user?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Name & Role
            VStack(spacing: 6) {
                Text(user?.name ?? "Pengguna")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: roleIcon)
                        .font(.caption)
                    Text(user?.roleDisplayName ?? "Warga")
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(15)
            }
            
            // Email
            HStack {
                Image(systemName: "envelope")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user?.email ?? "user@example.com")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    var roleIcon: String {
        switch user?.role {
        case "admin": return "shield.fill"
        case "technician": return "wrench.fill"
        case "community_leader": return "person.3.fill"
        default: return "person.fill"
        }
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    @EnvironmentObject var reportController: ReportController
    
    var body: some View {
        HStack(spacing: 15) {
            ProfileStatCard(
                title: "Total Laporan",
                value: "\(reportController.reports.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            ProfileStatCard(
                title: "Diproses",
                value: "\(reportController.inProgressReports.count)",
                icon: "clock.fill",
                color: .orange
            )
            
            ProfileStatCard(
                title: "Selesai",
                value: "\(reportController.completedReports.count)",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
        .padding(.horizontal)
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 45, height: 45)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
