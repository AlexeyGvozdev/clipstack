//
//  PreviewView.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import SwiftUI

/// Main preview window view for displaying clipboard history
struct PreviewView: View {
    @ObservedObject var clipBuffer: ClipBuffer
    
    @State private var searchText = ""
    @State private var selectedContentType: ClipItem.ContentType?
    
    var onCopyItem: (ClipItem) -> Void
    var onDeleteItem: (ClipItem) -> Void
    var onClearAll: () -> Void
    
    // Filtered items based on search and content type
    private var filteredItems: [ClipItem] {
        var items = clipBuffer.items
        
        // Filter by content type if selected
        if let contentType = selectedContentType {
            items = items.filter { $0.contentType == contentType }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items.reversed() // Show newest first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Search and filter bar
            searchAndFilterBar
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(NSColor.separatorColor)),
                    alignment: .bottom
                )
            
            // Items list
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsList
            }
        }
        .frame(minWidth: 650, minHeight: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            // Add subtle animation on appear
            withAnimation(.easeOut(duration: 0.3)) {
                // Animation handled by individual components
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.clipboard.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.accentColor)
                    
                    Text("ClipStack History")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(clipBuffer.count) items")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: clipBuffer.mode.icon)
                            .font(.system(size: 12, weight: .medium))
                        Text(clipBuffer.mode.displayName)
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onClearAll) {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text("Clear All")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(clipBuffer.isEmpty ? Color.gray.opacity(0.3) : Color.red)
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .disabled(clipBuffer.isEmpty)
            .scaleEffect(clipBuffer.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: clipBuffer.isEmpty)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(NSColor.windowBackgroundColor), Color(NSColor.controlBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        HStack(spacing: 16) {
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Search clipboard history...", text: $searchText)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(NSColor.controlAccentColor).opacity(searchText.isEmpty ? 0.3 : 0.8), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Content type filter
            Menu {
                Button("All Types") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedContentType = nil
                    }
                }
                
                Divider()
                
                ForEach(ClipItem.ContentType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedContentType = selectedContentType == type ? nil : type
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(contentTypeColor(for: type))
                            
                            Text(type.displayName)
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            if selectedContentType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: selectedContentType?.icon ?? "line.3.horizontal.decrease.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedContentType != nil ? contentTypeColor(for: selectedContentType!) : .secondary)
                    
                    Text(selectedContentType?.displayName ?? "Filter")
                        .font(.system(size: 14, weight: .medium))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedContentType != nil ? contentTypeColor(for: selectedContentType!).opacity(0.15) : Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedContentType != nil ? contentTypeColor(for: selectedContentType!).opacity(0.5) : Color(NSColor.separatorColor), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Items List
    
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    ClipItemRowView(
                        item: item,
                        onCopy: { onCopyItem(item) },
                        onDelete: { onDeleteItem(item) }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: filteredItems.count)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: searchText.isEmpty && selectedContentType == nil ? "doc.on.clipboard" : "magnifyingglass")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.accentColor)
                    .scaleEffect(searchText.isEmpty && selectedContentType == nil ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.3), value: (searchText.isEmpty && selectedContentType == nil))
            }
            
            VStack(spacing: 12) {
                Text(searchText.isEmpty && selectedContentType == nil
                     ? "No clipboard history yet"
                     : "No items match your search")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(searchText.isEmpty && selectedContentType == nil
                     ? "Copy something to get started"
                     : "Try adjusting your search or filter")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty && selectedContentType == nil {
                Button(action: {
                    // Could trigger a tutorial or help
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 14, weight: .medium))
                        Text("Learn How to Use ClipStack")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .scaleEffect(1.0)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        // Hover effect handled by the button
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Helper Methods
    
    private func contentTypeColor(for type: ClipItem.ContentType) -> Color {
        switch type {
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
}

// MARK: - Preview

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let buffer = ClipBuffer()
        buffer.push(ClipItem(
            content: "Hello, World! This is a test clipboard item.",
            sourceApp: "Safari",
            contentType: .plainText
        ))
        buffer.push(ClipItem(
            content: "https://github.com/AlexeyGvozdev/clipstack",
            sourceApp: "Chrome",
            contentType: .url
        ))
        buffer.push(ClipItem(
            content: "func example() { print(\"Hello\") }",
            sourceApp: "Xcode",
            contentType: .code
        ))
        
        return PreviewView(
            clipBuffer: buffer,
            onCopyItem: { _ in },
            onDeleteItem: { _ in },
            onClearAll: {}
        )
    }
}