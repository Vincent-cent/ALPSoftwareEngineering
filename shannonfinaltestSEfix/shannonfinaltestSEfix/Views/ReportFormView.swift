//
//  ReportFormView.swift
//  shannonfinaltestSEfix
//
//  Halaman form buat laporan baru
//

import SwiftUI

struct ReportFormView: View {
    @State private var selectedCategory = "Pipa Bocor"
    @State private var location = ""
    @State private var description = ""
    @State private var isUrgent = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showSuccess = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss
    
    let categories = ReportCategory.allCategories
    
    var isFormValid: Bool {
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                if reportController.isLoading {
                    ProgressView("Mengirim laporan...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                        
                            InfoHeader()
                            
                            
                            CategorySection(
                                selectedCategory: $selectedCategory,
                                categories: categories
                            )
                            
                    
                            LocationSection(location: $location)
                            
                            // Description Input
                            DescriptionSection(description: $description)
                            
                            // Photo Upload
                            PhotoSection(
                                selectedImage: $selectedImage,
                                showImagePicker: $showImagePicker
                            )
                            
                            // Urgent Toggle
                            UrgentToggle(isUrgent: $isUrgent)
                            
                            // Submit Button
                            SubmitButton(
                                isEnabled: isFormValid,
                                isLoading: reportController.isLoading
                            ) {
                                submitReport()
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Buat Laporan Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: $selectedImage)
            }
            .alert("Berhasil!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Laporan kamu telah dikirim. Tim kami akan segera memprosesnya. Terima kasih!")
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitReport() {
        guard isFormValid else {
            alertMessage = "Mohon lengkapi lokasi dan deskripsi"
            showAlert = true
            return
        }
        
        reportController.addReport(
            title: selectedCategory,
            category: selectedCategory,
            location: location,
            description: description,
            image: selectedImage,
            isUrgent: isUrgent
        )
        
        showSuccess = true
    }
}


struct InfoHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.title3)
            
            Text("Isi form berikut untuk melaporkan masalah air atau sanitasi di lingkungan Anda")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
    }
}


struct CategorySection: View {
    @Binding var selectedCategory: String
    let categories: [ReportCategory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jenis Masalah")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.name) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category.name
                        ) {
                            selectedCategory = category.name
                        }
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let category: ReportCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? category.color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct LocationSection: View {
    @Binding var location: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Lokasi Kejadian")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("(Wajib)")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                TextField("Contoh: Jl. Mawar No.5, RT02/RW03", text: $location)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}


struct DescriptionSection: View {
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Deskripsi Masalah")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("(Wajib)")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            
            TextEditor(text: $description)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Text("Jelaskan secara detail agar petugas cepat merespon")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}


struct PhotoSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Foto Bukti")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Button(action: {
                showImagePicker = true
            }) {
                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(12)
                        
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(8)
                    }
                } else {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tambah Foto")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Ambil foto atau pilih dari galeri")
                                .font(.caption2)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


struct UrgentToggle: View {
    @Binding var isUrgent: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Prioritas Darurat")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Centang jika masalah sangat mendesak dan berbahaya")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isUrgent)
                .toggleStyle(SwitchToggleStyle(tint: .red))
        }
        .padding()
        .background(isUrgent ? Color.red.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
    }
}


struct SubmitButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Kirim Laporan")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled && !isLoading ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
    }
}


struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ReportFormView()
        .environmentObject(ReportController())
}
