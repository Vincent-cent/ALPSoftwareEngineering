//
//  ReportHistoryView.swift
//  shannonfinaltestSEfix
//
//  Halaman riwayat laporan
//

import SwiftUI

struct ReportHistoryView: View {
    @EnvironmentObject var reportController: ReportController
    @State private var searchText = ""
    @State private var selectedFilter = "Semua"
    
    let filters = ["Semua", "Pending", "In Progress", "Completed"]
    
    var filteredReports: [ReportModel] {
        var filtered = reportController.reports
        
     
        if selectedFilter != "Semua" {
            filtered = filtered.filter { $0.status == selectedFilter }
        }
        
       
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.reportId.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Cari laporan...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("Batal") {
                            searchText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
        
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                withAnimation {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
               
                if filteredReports.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(filteredReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report)) {
                                ReportCard(report: report)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Riwayat Laporan")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}


struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
            }
            
            Text("Belum Ada Laporan")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Laporan yang kamu buat akan muncul di sini")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: ReportFormView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Buat Laporan Sekarang")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
}


struct ReportDetailView: View {
    let report: ReportModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(report.reportId)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(report.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: report.status)
                }
                
                Divider()
                
                // Category
                DetailRow(
                    icon: "tag.fill",
                    title: "Kategori",
                    value: report.category,
                    color: .blue
                )
                
                // Location
                DetailRow(
                    icon: "location.fill",
                    title: "Lokasi",
                    value: report.location,
                    color: .orange
                )
                
                // Date
                DetailRow(
                    icon: "calendar",
                    title: "Tanggal Laporan",
                    value: formattedDate(report.date),
                    color: .green
                )
                
                // Urgent
                if report.isUrgent {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Laporan Prioritas Darurat")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Deskripsi")
                        .font(.headline)
                    
                    Text(report.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Photo
                if let image = report.image {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Bukti")
                            .font(.headline)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                }
                
                // Timeline
                VStack(alignment: .leading, spacing: 15) {
                    Text("Status Timeline")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    TimelineItem(
                        status: "Laporan Dikirim",
                        isCompleted: true,
                        date: report.date
                    )
                    
                    TimelineItem(
                        status: "Diverifikasi",
                        isCompleted: report.status != "Pending",
                        date: report.status != "Pending" ? report.date : nil
                    )
                    
                    TimelineItem(
                        status: "Sedang Diproses",
                        isCompleted: report.status == "In Progress" || report.status == "Completed",
                        date: report.status == "In Progress" || report.status == "Completed" ? report.date : nil
                    )
                    
                    TimelineItem(
                        status: "Selesai",
                        isCompleted: report.status == "Completed",
                        date: report.status == "Completed" ? report.date : nil
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Detail Laporan")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}


struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 35, height: 35)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}


struct TimelineItem: View {
    let status: String
    let isCompleted: Bool
    let date: Date?
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(status)
                    .font(.subheadline)
                    .fontWeight(isCompleted ? .semibold : .regular)
                    .foregroundColor(isCompleted ? .primary : .gray)
                
                if let date = date, isCompleted {
                    Text(formattedDate(date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}

#Preview {
    ReportHistoryView()
        .environmentObject(ReportController())
}
