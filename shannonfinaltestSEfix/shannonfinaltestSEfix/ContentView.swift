//
//  ContentView.swift
//  shannonfinaltestSEfix
//
//  Main entry point - routing berdasarkan status login
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var authController = AuthController()
    @StateObject private var reportController = ReportController()
    
    var body: some View {
        Group {
            if isLoggedIn {
                HomeView()
                    .environmentObject(authController)
                    .environmentObject(reportController)
            } else {
                LoginView()
                    .environmentObject(authController)
                    .environmentObject(reportController)
            }
        }
    }
}

#Preview {
    ContentView()
}
