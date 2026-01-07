//
//  ToastView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 07/01/26.
//

import SwiftUI

public struct ToastStyle {
    public var iconSystemName: String
    public var iconColor: Color
    public var backgroundColor: Color
    public var borderColor: Color
    public var textColor: Color
    public var cornerRadius: CGFloat
    public var shadow: Color

    public init(
        iconSystemName: String = "checkmark.circle.fill",
        iconColor: Color = .green,
        backgroundColor: Color = Color.black.opacity(0.85),
        borderColor: Color = Color.white.opacity(0.12),
        textColor: Color = .white,
        cornerRadius: CGFloat = 12,
        shadow: Color = Color.black.opacity(0.4)
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }

    public static var success = ToastStyle()
    public static var error = ToastStyle(
        iconSystemName: "xmark.octagon.fill",
        iconColor: .red
    )
    public static var info = ToastStyle(
        iconSystemName: "info.circle.fill",
        iconColor: .blue
    )
}

public struct ToastView: View {
    private let message: String
    private let style: ToastStyle

    public init(message: String, style: ToastStyle = .success) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: style.iconSystemName)
                .foregroundColor(style.iconColor)
            Text(message)
                .foregroundColor(style.textColor)
                .font(.subheadline.bold())
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(style.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .shadow(color: style.shadow, radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    VStack(spacing: 16) {
        ToastView(message: "Saved successfully")
        ToastView(message: "Something went wrong", style: .error)
        ToastView(message: "Heads up! Info here.", style: .info)
    }
    .padding()
    .background(Color.black)
    .previewLayout(.sizeThatFits)
}
