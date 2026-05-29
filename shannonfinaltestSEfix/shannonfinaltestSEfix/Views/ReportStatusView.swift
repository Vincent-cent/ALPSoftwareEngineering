//
//  ReportStatusView.swift
//  shannonfinaltestSEfix
//
//  Halaman status laporan (grouped by status)
//

import SwiftUI

struct ReportStatusView: View {
    @EnvironmentObject var reportController: ReportController
    @State private var selectedStatus = "Semua"
    
    let statusOptions = ["Semua", "Pending", "Verified", "In Progress", "Completed", "Rejected"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
               
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(statusOptions, id: \.self) { status in
                            StatusTab(
                                title: status,
                                isSelected: selectedStatus == status,
                                count: getCountForStatus(status)
                            ) {
                                withAnimation {
                                    selectedStatus = status
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedStatus == "Semua" {
                            // Show all status groups
                            ForEach(["Pending", "In Progress", "Completed"], id: \.self) { status in
                                if !getReportsForStatus(status).isEmpty {
                                    StatusGroupSection(
                                        status: status,
                                        reports: getReportsForStatus(status)
                                    )
                                }
                            }
                        } else {
                            // iki buat show single status
                            let reports = getReportsForStatus(selectedStatus)
                            if reports.isEmpty {
                                EmptyStatusView(status: selectedStatus)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(reports) { report in
                                        NavigationLink(destination: ReportDetailView(report: report)) {
                                            StatusCard(report: report)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Status Laporan")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func getCountForStatus(_ status: String) -> Int {
        if status == "Semua" {
            return reportController.reports.count
        }
        return reportController.reports.filter { $0.status == status }.count
    }
    
    private func getReportsForStatus(_ status: String) -> [ReportModel] {
        if status == "Semua" {
            return []
        }
        return reportController.reports.filter { $0.status == status }
    }
}


struct StatusTab: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var statusColor: Color {
        switch title {
        case "Pending": return .orange
        case "Verified": return .blue
        case "In Progress": return .green
        case "Completed": return .gray
        case "Rejected": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? statusColor : .gray)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isSelected ? statusColor.opacity(0.15) : Color(.systemGray5))
                    .foregroundColor(isSelected ? statusColor : .gray)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? statusColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct StatusGroupSection: View {
    let status: String
    let reports: [ReportModel]
    
    var statusColor: Color {
        switch status {
        case "Pending": return .orange
        case "Verified": return .blue
        case "In Progress": return .green
        case "Completed": return .gray
        case "Rejected": return .red
        default: return .blue
        }
    }
    
    var statusIcon: String {
        switch status {
        case "Pending": return "clock.fill"
        case "Verified": return "checkmark.seal.fill"
        case "In Progress": return "arrow.triangle.2.circlepath"
        case "Completed": return "checkmark.circle.fill"
        case "Rejected": return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                
                Text(status)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(reports.count) laporan")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            
            VStack(spacing: 10) {
                ForEach(reports.prefix(3)) { report in
                    NavigationLink(destination: ReportDetailView(report: report)) {
                        CompactStatusCard(report: report)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if reports.count > 3 {
                    NavigationLink(destination: StatusDetailView(status: status, reports: reports)) {
                        Text("Lihat \(reports.count - 3) laporan lainnya")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}


struct CompactStatusCard: View {
    let report: ReportModel
    
    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(report.statusColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(report.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(report.location)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(formattedDate(report.date))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}


struct StatusCard: View {
    let report: ReportModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                
                Circle()
                    .fill(report.statusColor)
                    .frame(width: 12, height: 12)
                
                Text(report.status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(report.statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(report.statusColor.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(report.reportId)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(report.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(report.location)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(formattedDate(report.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if report.isUrgent {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text("Prioritas Darurat")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}


struct EmptyStatusView: View {
    let status: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 35))
                    .foregroundColor(.gray)
            }
            
            Text("Tidak Ada Laporan")
                .font(.headline)
            
            Text("Tidak ada laporan dengan status \"\(status)\"")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}


struct StatusDetailView: View {
    let status: String
    let reports: [ReportModel]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(reports) { report in
                    NavigationLink(destination: ReportDetailView(report: report)) {
                        StatusCard(report: report)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .navigationTitle(status)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ReportStatusView()
        .environmentObject(ReportController())
}
