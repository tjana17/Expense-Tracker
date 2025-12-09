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
        NavigationStack {
            ZStack {
                Image("get-started")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Button {
                        debugPrint("Tapped..")
                        showHomeView = true
                    } label: {
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color.clear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .fullScreenCover(isPresented: $showHomeView) {
                ExpenseHomeView()
            }
            
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
