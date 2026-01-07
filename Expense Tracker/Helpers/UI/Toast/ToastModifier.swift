//
//  ToastModifier.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 07/01/26.
//

import SwiftUI

public struct ToastState: Equatable {
    let id = UUID()
    public var message: String = ""
    public var style: ToastStyle = .success
    public var isPresented: Bool = false
    
    public static func == (lhs: ToastState, rhs: ToastState) -> Bool {
            lhs.id == rhs.id
        }

    public init(message: String = "", style: ToastStyle = .success, isPresented: Bool = false) {
        self.message = message
        self.style = style
        self.isPresented = isPresented
    }
}

private struct ToastOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let style: ToastStyle

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    GeometryReader { proxy in
                        let topSafe = proxy.safeAreaInsets.top
                        ToastView(message: message, style: style)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                            .padding(.horizontal, 16)
                            .padding(.top, topSafe + 12)
                    }
                    .allowsHitTesting(false)
                    .frame(height: 0)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

public extension View {
    // Simple API with separate pieces of state
    func toast(isPresented: Binding<Bool>, message: String, style: ToastStyle = .success) -> some View {
        modifier(ToastOverlayModifier(isPresented: isPresented, message: message, style: style))
    }

    // Alternative API: single bound ToastState
    func toast(state: Binding<ToastState>) -> some View {
        modifier(
            ToastOverlayModifier(
                isPresented: Binding(
                    get: { state.wrappedValue.isPresented },
                    set: { state.wrappedValue.isPresented = $0 }
                ),
                message: state.wrappedValue.message,
                style: state.wrappedValue.style
            )
        )
    }
}
