//
//  ModernButton.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import SwiftUI

/// Modern button with enhanced styling and animations
struct ModernButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case accent
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Color.accentColor
            case .secondary: return Color(NSColor.controlBackgroundColor)
            case .destructive: return Color.red
            case .accent: return Color.accentColor.opacity(0.8)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .accent: return .white
            case .secondary: return .primary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary, .destructive, .accent: return .clear
            case .secondary: return Color(NSColor.separatorColor)
            }
        }
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style.borderColor, lineWidth: style == .secondary ? 1 : 0)
                    )
            )
            .foregroundColor(style.foregroundColor)
            .scaleEffect(isPressed ? 0.95 : isHovered ? 1.02 : 1.0)
            .shadow(color: shadowColor, radius: isHovered ? 4 : 2, x: 0, y: isHovered ? 2 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
        .pressEvents(
            onPress: { withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } },
            onRelease: { withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return style.backgroundColor.opacity(0.8)
        } else if isHovered {
            return style.backgroundColor.opacity(0.9)
        } else {
            return style.backgroundColor
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary, .accent:
            return Color.accentColor.opacity(isHovered ? 0.3 : 0.2)
        case .destructive:
            return Color.red.opacity(isHovered ? 0.3 : 0.2)
        case .secondary:
            return Color.black.opacity(isHovered ? 0.1 : 0.05)
        }
    }
}

// MARK: - Preview

struct ModernButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ModernButton(title: "Primary Action", icon: "plus.circle", style: .primary) { }
            ModernButton(title: "Secondary Action", icon: "gear", style: .secondary) { }
            ModernButton(title: "Delete", icon: "trash", style: .destructive) { }
            ModernButton(title: "Accent", icon: "star", style: .accent) { }
        }
        .padding()
    }
}