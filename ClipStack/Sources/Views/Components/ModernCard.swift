//
//  ModernCard.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import SwiftUI

/// Modern card component with enhanced styling and animations
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let backgroundColor: Color
    
    @State private var isHovered = false
    
    init(
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        backgroundColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(isHovered ? 0.15 : 0.08),
                radius: isHovered ? shadowRadius + 2 : shadowRadius,
                x: 0,
                y: isHovered ? 4 : 2
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isHovered = hovering
                }
            }
    }
}

/// Specialized card for settings sections
struct SettingsSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    @State private var isHovered = false
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(20)
            .padding(.bottom, 16)
            
            // Content
            content
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
        )
        .shadow(
            color: Color.black.opacity(isHovered ? 0.12 : 0.06),
            radius: isHovered ? 6 : 4,
            x: 0,
            y: isHovered ? 3 : 2
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
}

/// Card for displaying statistics or metrics
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: Trend?
    
    enum Trend {
        case up(Double)
        case down(Double)
        case stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .secondary
            }
        }
        
        var description: String {
            switch self {
            case .up(let value): return "+\(String(format: "%.1f", value))%"
            case .down(let value): return "-\(String(format: "%.1f", value))%"
            case .stable: return "0%"
            }
        }
    }
    
    init(title: String, value: String, icon: String, color: Color, trend: Trend? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.system(size: 12, weight: .medium))
                        Text(trend.description)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(trend.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(trend.color.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

struct ModernCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ModernCard {
                Text("This is a modern card")
                    .font(.headline)
                Text("With enhanced styling and animations")
                    .foregroundColor(.secondary)
            }
            
            SettingsSectionCard(title: "General Settings", icon: "gear") {
                Text("Settings content goes here")
                    .foregroundColor(.secondary)
            }
            
            MetricCard(
                title: "Total Items",
                value: "42",
                icon: "doc.on.clipboard",
                color: .blue,
                trend: .up(12.5)
            )
        }
        .padding()
    }
}