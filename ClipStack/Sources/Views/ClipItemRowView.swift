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
    
    var body: some View {
        HStack(spacing: 12) {
            // Content type icon
            Image(systemName: item.contentType.icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            // Content preview
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Content type badge
                    Text(item.contentType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                    
                    // Timestamp
                    Text(item.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Source app if available
                    if let sourceApp = item.sourceApp {
                        Text("• \(sourceApp)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons (shown on hover)
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .help("Copy to clipboard")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Delete item")
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}