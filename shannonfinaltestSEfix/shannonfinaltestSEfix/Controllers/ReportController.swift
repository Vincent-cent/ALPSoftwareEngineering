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
import FirebaseFirestore
import Combine

class ReportController: ObservableObject {
    @Published var reports: [ReportModel] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    init() {
        dengarkanSemuaLaporanDariServer()
    }
    
    func addReport(title: String, category: String, location: String, description: String, image: UIImage?, isUrgent: Bool) {
        isLoading = true
        
        var imageString: String? = nil
        if let imageData = image?.jpegData(compressionQuality: 0.5) {
            imageString = imageData.base64EncodedString()
        }
        
        let reportIdNew = "AQ-\(Int.random(in: 100...999))"
        
        let reportData: [String: Any] = [
            "reportId": reportIdNew,
            "title": title,
            "category": category,
            "location": location,
            "description": description.isEmpty ? "Tidak ada deskripsi" : description,
            "image_base64": imageString ?? "",
            "status": "Pending",
            "date": Timestamp(date: Date()),
            "isUrgent": isUrgent
        ]
        
        db.collection("reports").document(reportIdNew).setData(reportData) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let e = error {
                    print("Gagal mengirim laporan: \(e.localizedDescription)")
                } else {
                    print("Laporan berhasil diunggah secara global!")
                }
            }
        }
    }
    
    func dengarkanSemuaLaporanDariServer() {
        db.collection("reports").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Gagal mengambil data laporan: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.reports = documents.map { doc -> ReportModel in
                    let data = doc.data()
                    let reportId = data["reportId"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let category = data["category"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let status = data["status"] as? String ?? "Pending"
                    let isUrgent = data["isUrgent"] as? Bool ?? false
                    
                    let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                    let date = timestamp.dateValue()
                    
                    var imageData: Data? = nil
                    if let base64String = data["image_base64"] as? String, !base64String.isEmpty {
                        imageData = Data(base64Encoded: base64String)
                    }
                    
                    return ReportModel(
                        reportId: reportId,
                        title: title,
                        category: category,
                        location: location,
                        description: description,
                        imageData: imageData,
                        status: status,
                        date: date,
                        isUrgent: isUrgent
                    )
                }
            }
        }
    }
    
    func updateReportStatus(reportId: String, newStatus: String) {
        db.collection("reports").document(reportId).updateData([
            "status": newStatus
        ]) { error in
            if let e = error {
                print("Gagal mengupdate status: \(e.localizedDescription)")
            }
        }
    }
    
    func assignTechnicianAndStatus(reportId: String, newStatus: String, technicianName: String) {
            db.collection("reports").document(reportId).updateData([
                "status": newStatus,
                "assigned_technician": technicianName
            ]) { error in
                if let e = error {
                    print("Gagal menugaskan teknisi: \(e.localizedDescription)")
                } else {
                    print("Berhasil menugaskan teknisi \(technicianName) dan mengubah status ke \(newStatus)")
                }
            }
        }
    
    func getReportsByStatus(status: String) -> [ReportModel] {
        return reports.filter { $0.status == status }
    }
    
    func getReportsByUser(userId: String) -> [ReportModel] {
        return reports
    }
    
    var pendingReports: [ReportModel] { reports.filter { $0.status == "Pending" } }
    var inProgressReports: [ReportModel] { reports.filter { $0.status == "In Progress" } }
    var completedReports: [ReportModel] { reports.filter { $0.status == "Completed" } }
}
