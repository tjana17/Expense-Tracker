//
//  CustomTabBar.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI

struct CustomTabBar: View {

    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 40) {

            tabButton(icon: "house.fill", index: 0)
            tabButton(icon: "chart.pie.fill", index: 1)
            bigCenterButton
            tabButton(icon: "wallet.bifold.fill", index: 2)
            tabButton(icon: "person.fill", index: 3)

        }
        .padding()
        .background(Color.black.opacity(0.9))
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    private func tabButton(icon: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
        }
    }

    private var bigCenterButton: some View {
        Button {
            selectedTab = 10
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 55, height: 55)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
    }
}
