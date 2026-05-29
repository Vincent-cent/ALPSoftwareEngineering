//
//  ReportModel.swift
//  shannonfinaltestSEfix
//
//  Model untuk data laporan dan user
//

import Foundation
import SwiftUI

// MARK: - Report Model
struct ReportModel: Identifiable {
    let id = UUID()
    let reportId: String
    let title: String
    let category: String
    let location: String
    let description: String
    let imageData: Data?
    let status: String
    let date: Date
    let isUrgent: Bool
    
    // Computed property untuk UIImage
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    // Status color for badge
    var statusColor: Color {
        switch status {
        case "Pending": return .orange
        case "Verified": return .blue
        case "In Progress": return .green
        case "Completed": return .gray
        case "Rejected": return .red
        default: return .gray
        }
    }
    
    // Sample data untuk preview
    static let sampleReports = [
        ReportModel(
            reportId: "AQ-001",
            title: "Pipa PDAM Bocor",
            category: "Pipa Bocor",
            location: "Jl. Mawar No.5, RT02/RW03",
            description: "Air mengalir deras sejak 2 hari, jalanan becek dan licin. Mengganggu aktivitas warga.",
            imageData: nil,
            status: "Pending",
            date: Date().addingTimeInterval(-86400 * 3),
            isUrgent: true
        ),
        ReportModel(
            reportId: "AQ-002",
            title: "Saluran Drainase Mampet",
            category: "Saluran Mampet",
            location: "Gg. Melati, belakang masjid",
            description: "Air tidak mengalir, bau tidak sedap, nyamuk banyak. Khawatir jadi sarang penyakit.",
            imageData: nil,
            status: "In Progress",
            date: Date().addingTimeInterval(-86400 * 2),
            isUrgent: false
        ),
        ReportModel(
            reportId: "AQ-003",
            title: "Air Keruh dan Berpasir",
            category: "Kualitas Air",
            location: "Perumahan Asri Blok C No.12",
            description: "Air dari keran berwarna coklat, tidak layak minum, ada bau tanah.",
            imageData: nil,
            status: "Completed",
            date: Date().addingTimeInterval(-86400 * 5),
            isUrgent: false
        )
    ]
}

// MARK: - User Model
struct UserModel {
    let id: String
    let name: String
    let email: String
    let role: String
    let avatarColor: Color
    
    var roleDisplayName: String {
        switch role {
        case "resident": return "Warga"
        case "community_leader": return "Ketua RT/RW"
        case "admin": return "Admin"
        case "technician": return "Teknisi"
        case "system_admin": return "System Admin"
        default: return "Warga"
        }
    }
    
    init(id: String, name: String, email: String, role: String, avatarColor: Color? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor ?? {
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
            let hash = abs(name.hashValue)
            return colors[hash % colors.count]
        }()
    }
}

// MARK: - Category Model
struct ReportCategory {
    let name: String
    let icon: String
    let color: Color
    
    static let allCategories = [
        ReportCategory(name: "Pipa Bocor", icon: "drop.fill", color: .blue),
        ReportCategory(name: "Saluran Mampet", icon: "flowchart.fill", color: .orange),
        ReportCategory(name: "Kualitas Air", icon: "eyedropper.full", color: .green),
        ReportCategory(name: "Fasilitas Rusak", icon: "wrench.fill", color: .red),
        ReportCategory(name: "Lainnya", icon: "exclamationmark.triangle.fill", color: .gray)
    ]
}
