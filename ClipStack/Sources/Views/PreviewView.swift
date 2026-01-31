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
            
            Divider()
            
            // Search and filter bar
            searchAndFilterBar
            
            Divider()
            
            // Items list
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsList
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ClipStack History")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(clipBuffer.count) items • \(clipBuffer.mode.displayName) mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onClearAll) {
                Label("Clear All", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(clipBuffer.isEmpty)
        }
        .padding()
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search clipboard history...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Content type filter
            Menu {
                Button("All Types") {
                    selectedContentType = nil
                }
                
                Divider()
                
                ForEach(ClipItem.ContentType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedContentType = selectedContentType == type ? nil : type
                    }) {
                        Label(type.displayName, systemImage: type.icon)
                        if selectedContentType == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Label(
                    selectedContentType?.displayName ?? "Filter",
                    systemImage: selectedContentType?.icon ?? "line.3.horizontal.decrease.circle"
                )
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Items List
    
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredItems) { item in
                    VStack(spacing: 0) {
                        ClipItemRowView(
                            item: item,
                            onCopy: { onCopyItem(item) },
                            onDelete: { onDeleteItem(item) }
                        )
                        
                        if item.id != filteredItems.last?.id {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty && selectedContentType == nil
                 ? "No clipboard history yet"
                 : "No items match your search")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty && selectedContentType == nil
                 ? "Copy something to get started"
                 : "Try adjusting your search or filter")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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