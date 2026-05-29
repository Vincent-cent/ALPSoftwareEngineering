//
//  ReportController.swift
//  shannonfinaltestSEfix
//
//  Controller untuk manajemen laporan
//

// ini sek pakai dummy data
// hrs di hub ke firebacse
import Foundation
import SwiftUI
import Combine

class ReportController: ObservableObject {
    @Published var reports: [ReportModel] = []
    @Published var isLoading = false
    
    init() {
        loadSampleReports()
    }
    
    func loadSampleReports() {
        reports = ReportModel.sampleReports
    }
    
    func addReport(title: String, category: String, location: String, description: String, image: UIImage?, isUrgent: Bool) {
        isLoading = true
        
        // Simulasi delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let newReport = ReportModel(
                reportId: "AQ-" + String(format: "%03d", self.reports.count + 1),
                title: title,
                category: category,
                location: location,
                description: description.isEmpty ? "Tidak ada deskripsi" : description,
                imageData: image?.jpegData(compressionQuality: 0.8),
                status: "Pending",
                date: Date(),
                isUrgent: isUrgent
            )
            
            self.reports.insert(newReport, at: 0)
            self.isLoading = false
        }
    }
    
    func updateReportStatus(reportId: String, newStatus: String) {
        if let index = reports.firstIndex(where: { $0.reportId == reportId }) {
            let report = reports[index]
            let updatedReport = ReportModel(
                reportId: report.reportId,
                title: report.title,
                category: report.category,
                location: report.location,
                description: report.description,
                imageData: report.imageData,
                status: newStatus,
                date: report.date,
                isUrgent: report.isUrgent
            )
            reports[index] = updatedReport
        }
    }
    
    func getReportsByStatus(status: String) -> [ReportModel] {
        return reports.filter { $0.status == status }
    }
    
    func getReportsByUser(userId: String) -> [ReportModel] {
        // Untuk demo, return semua laporan
        // Di real app, filter by userId
        return reports
    }
    
    var pendingReports: [ReportModel] {
        reports.filter { $0.status == "Pending" }
    }
    
    var inProgressReports: [ReportModel] {
        reports.filter { $0.status == "In Progress" }
    }
    
    var completedReports: [ReportModel] {
        reports.filter { $0.status == "Completed" }
    }
}
