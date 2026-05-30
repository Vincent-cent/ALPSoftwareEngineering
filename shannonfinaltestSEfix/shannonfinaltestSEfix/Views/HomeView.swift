//
//  HomeView.swift
//  shannonfinaltestSEfix
//
//  Halaman utama setelah login
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if authController.currentUser?.role == "admin" {
                            AdminHomeView()
                                .tabItem {
                                    Label("Dashboard", systemImage: "shield.fill")
                                }
                                .tag(0)
                        } else {
                            HomeMainView()
                                .tabItem {
                                    Label("Beranda", systemImage: "house.fill")
                                }
                                .tag(0)
                        }
            
            ReportHistoryView()
                .tabItem {
                    Label("Laporan", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            ReportStatusView()
                .tabItem {
                    Label("Status", systemImage: "chart.line.text.clipboard")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct HomeMainView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selamat Datang,")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(authController.currentUser?.name ?? "Pengguna")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(authController.currentUser?.avatarColor ?? .blue)
                                    .frame(width: 45, height: 45)
                                
                                Text(String(authController.currentUser?.name.prefix(1) ?? "U").uppercased())
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    StatsRow(reportController: reportController)
                        .padding(.horizontal)

                    QuickActionsSection()
                        .padding(.horizontal)
                    
                    InfoCard()
                        .padding(.horizontal)
                    
                    RecentReportsSection(reports: Array(reportController.reports.prefix(3)))
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                }
            }
            .navigationBarHidden(true)
            .alert("Keluar Akun", isPresented: $showLogoutAlert) {
                Button("Batal", role: .cancel) { }
                Button("Keluar", role: .destructive) {
                    authController.logout()
                }
            } message: {
                Text("Apakah Anda yakin ingin keluar dari aplikasi?")
            }
        }
    }
}


struct WelcomeHeader: View {
    let userName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Halo, 👋")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Ada masalah air atau sanitasi? Laporkan sekarang!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            Spacer()
            
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
                    .frame(width: 55, height: 55)
                
                Text(String(userName.prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 20)
    }
}


struct StatsRow: View {
    @ObservedObject var reportController: ReportController
    
    var body: some View {
        HStack(spacing: 15) {
            StatCard(
                title: "Total",
                value: "\(reportController.reports.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatCard(
                title: "Diproses",
                value: "\(reportController.inProgressReports.count)",
                icon: "clock.fill",
                color: .orange
            )
            
            StatCard(
                title: "Selesai",
                value: "\(reportController.completedReports.count)",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }
}

struct StatCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Aksi Cepat")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 15) {
                NavigationLink(destination: ReportFormView()) {
                    QuickActionCard(
                        icon: "plus.circle.fill",
                        title: "Buat Laporan",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: ReportHistoryView()) {
                    QuickActionCard(
                        icon: "clock.fill",
                        title: "Riwayat",
                        color: .orange
                    )
                }
                
                NavigationLink(destination: ReportStatusView()) {
                    QuickActionCard(
                        icon: "chart.line.text.clipboard",
                        title: "Status",
                        color: .green
                    )
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.15))
                    .frame(height: 70)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}


struct RecentReportsSection: View {
    let reports: [ReportModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Laporan Terbaru")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: ReportHistoryView()) {
                    Text("Lihat Semua")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if reports.isEmpty {
                EmptyReportsCard()
            } else {
                ForEach(reports) { report in
                    ReportCard(report: report)
                }
            }
        }
    }
}

struct EmptyReportsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 45))
                .foregroundColor(.gray)
            
            Text("Belum ada laporan")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Tekan tombol Buat Laporan untuk memulai")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}


struct InfoCard: View {
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SDG 6: Air Bersih & Sanitasi")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Laporkan masalah untuk membantu lingkungan yang lebih sehat")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - BERANDA KHUSUS ADMIN
struct AdminHomeView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var showLogoutAlert = false
    
    @State private var selectedReport: ReportModel? = nil
    @State private var showActionSheet = false
    
    @State private var selectedStatus = "In Progress"
    @State private var technicianName = ""
    
    let statusOptions = ["Pending", "Verified", "In Progress", "Completed", "Rejected"]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Panel Admin")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(authController.currentUser?.name ?? "Admin")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button(action: { showLogoutAlert = true }) {
                        ZStack {
                            Circle().fill(Color.purple).frame(width: 45, height: 45)
                            Image(systemName: "shield.fill").foregroundColor(.white)
                        }
                    }
                }
                .padding()
                
                StatsRow(reportController: reportController)
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Manajemen Laporan Masuk")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    List(reportController.reports) { report in
                        Button(action: {
                            self.selectedReport = report
                            self.selectedStatus = report.status
                            self.technicianName = ""
                            self.showActionSheet = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(report.title).font(.headline).foregroundColor(.primary)
                                    Text(report.location).font(.caption).foregroundColor(.gray)
                                    Text("Status: \(report.status)")
                                        .font(.caption)
                                        .foregroundColor(report.statusColor)
                                        .bold()
                                }
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarHidden(true)
            .alert("Keluar Akun", isPresented: $showLogoutAlert) {
                Button("Batal", role: .cancel) { }
                Button("Keluar", role: .destructive) { authController.logout() }
            } message: { Text("Yakin ingin keluar?") }
            
            .sheet(isPresented: $showActionSheet) {
                if let report = selectedReport {
                    NavigationView {
                        Form {
                            Section(header: Text("Detail Laporan")) {
                                Text(report.title).bold()
                                Text(report.description).font(.caption).foregroundColor(.gray)
                            }
                            
                            Section(header: Text("Ubah Status")) {
                                Picker("Status", selection: $selectedStatus) {
                                    ForEach(statusOptions, id: \.self) {
                                        Text($0)
                                    }
                                }
                            }
                            
                            Section(header: Text("Tugaskan Teknisi")) {
                                TextField("Nama Teknisi (Misal: Pak Budi)", text: $technicianName)
                            }
                            
                            Button(action: {
                                reportController.assignTechnicianAndStatus(
                                    reportId: report.reportId,
                                    newStatus: selectedStatus,
                                    technicianName: technicianName.isEmpty ? "Belum ada" : technicianName
                                )
                                showActionSheet = false
                            }) {
                                Text("Simpan Perubahan")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                        }
                        .navigationTitle("Kelola Laporan")
                        .navigationBarItems(trailing: Button("Batal") { showActionSheet = false })
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
