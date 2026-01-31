//
//  ClipItemRowView.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import SwiftUI

/// View for displaying a single clipboard item in a list
struct ClipItemRowView: View {
    let item: ClipItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var showCopyFeedback = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Content type icon with background
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                    .shadow(color: iconBackgroundColor.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Image(systemName: item.contentType.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconForegroundColor)
            }
            
            // Content preview
            VStack(alignment: .leading, spacing: 6) {
                Text(item.preview)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 12) {
                    // Content type badge
                    HStack(spacing: 4) {
                        Image(systemName: item.contentType.icon)
                            .font(.system(size: 10, weight: .medium))
                        Text(item.contentType.displayName.uppercased())
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(contentTypeBadgeColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    
                    // Timestamp
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(item.formattedTimestamp)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    
                    // Source app if available
                    if let sourceApp = item.sourceApp {
                        HStack(spacing: 4) {
                            Image(systemName: "app")
                                .font(.system(size: 10))
                            Text(sourceApp)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons (shown on hover)
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showCopyFeedback = true
                    }
                    onCopy()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showCopyFeedback = false
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(showCopyFeedback ? Color.green : Color.blue)
                            .frame(width: 32, height: 32)
                            .shadow(color: showCopyFeedback ? Color.green.opacity(0.4) : Color.blue.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: showCopyFeedback ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .help("Copy to clipboard")
                
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 32, height: 32)
                            .shadow(color: Color.red.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .help("Delete item")
            }
            .opacity(isHovered ? 1.0 : 0.0)
            .scaleEffect(isHovered ? 1.0 : 0.8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rowBackgroundColor)
                .shadow(color: rowShadowColor, radius: isHovered ? 4 : 2, x: 0, y: isHovered ? 2 : 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
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
    
    // MARK: - Computed Properties
    
    private var iconBackgroundColor: Color {
        switch item.contentType {
        case .plainText: return Color.blue.opacity(0.15)
        case .url: return Color.green.opacity(0.15)
        case .code: return Color.purple.opacity(0.15)
        case .email: return Color.orange.opacity(0.15)
        case .image: return Color.pink.opacity(0.15)
        case .file: return Color.gray.opacity(0.15)
        case .color: return Color.red.opacity(0.15)
        case .phoneNumber: return Color.teal.opacity(0.15)
        }
    }
    
    private var iconForegroundColor: Color {
        switch item.contentType {
        case .plainText: return Color.blue
        case .url: return Color.green
        case .code: return Color.purple
        case .email: return Color.orange
        case .image: return Color.pink
        case .file: return Color.gray
        case .color: return Color.red
        case .phoneNumber: return Color.teal
        }
    }
    
    private var contentTypeBadgeColor: Color {
        switch item.contentType {
        case .plainText: return Color.blue
        case .url: return Color.green
        case .code: return Color.purple
        case .email: return Color.orange
        case .image: return Color.pink
        case .file: return Color.gray
        case .color: return Color.red
        case .phoneNumber: return Color.teal
        }
    }
    
    private var rowBackgroundColor: Color {
        if isHovered {
            return Color(NSColor.controlAccentColor).opacity(0.1)
        } else {
            return Color(NSColor.controlBackgroundColor)
        }
    }
    
    private var rowShadowColor: Color {
        if isHovered {
            return Color.black.opacity(0.1)
        } else {
            return Color.black.opacity(0.05)
        }
    }
}

// MARK: - Press Events Extension

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}