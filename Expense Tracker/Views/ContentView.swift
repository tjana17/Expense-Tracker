//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var showHomeView: Bool = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Get Started") {
                showHomeView = true
            }
        }
        .padding()
        .navigationTitle("Welcome")
        .fullScreenCover(isPresented: $showHomeView) {
            ExpenseHomeView()
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.8),
                Color.blue.opacity(0.8),
                Color.black
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
        .edgesIgnoringSafeArea(.all)
    }
}



//struct ExpenseAPIService {
//    static let shared = ExpenseAPIService()
//
//    func fetchDashboardData() async throws -> DashboardData {
//        let url = URL(string: "https://api.myexpensesapp.com/dashboard")!
//        let (data, _) = try await URLSession.shared.data(from: url)
//        return try JSONDecoder().decode(DashboardData.self, from: data)
//    }
//}
//
//struct DashboardData: Codable {
//    let balance: Double
//    let expense: Double
//    let income: Double
//    let insight: String
//    let transactions: [TransactionItem]
//    let chartPoints: [Double]
//}

//struct TransactionItem: Codable, Identifiable {
//    let id: UUID
//    let title: String
//    let categoryIcon: String
//    let date: String
//    let amount: Double
//    let isPositive: Bool
//}
