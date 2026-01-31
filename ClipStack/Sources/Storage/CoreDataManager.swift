//
//  CoreDataManager.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Foundation
import CoreData

/// Manager for Core Data operations
final class CoreDataManager {
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    
    // MARK: - Properties
    
    /// The persistent container for the application
    private let persistentContainer: NSPersistentContainer
    
    /// Main context for UI operations (main thread)
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Background context for heavy operations
    private var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    /// Auto-save interval in seconds
    private let autoSaveInterval: TimeInterval = 30.0
    
    /// Auto-save timer
    private var autoSaveTimer: Timer?
    
    // MARK: - Initialization
    
    private init() {
        // Try to create the persistent container with fallback handling
        let container: NSPersistentContainer
        
        // Try to load the model from the main bundle first
        if let modelURL = Bundle.main.url(forResource: "ClipStack", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: modelURL) {
            container = NSPersistentContainer(name: "ClipStack", managedObjectModel: model)
        } else {
            print("Warning: ClipStack.momd not found in main bundle, trying to load from all bundles")
            // Fallback: try to find the model in any bundle
            let bundles = Bundle.allBundles
            var foundModel: NSManagedObjectModel?
            
            for bundle in bundles {
                if let url = bundle.url(forResource: "ClipStack", withExtension: "momd") {
                    foundModel = NSManagedObjectModel(contentsOf: url)
                    break
                }
            }
            
            if let model = foundModel {
                container = NSPersistentContainer(name: "ClipStack", managedObjectModel: model)
            } else {
                // Create a minimal model as fallback
                print("Creating minimal Core Data model as fallback")
                let model = Self.createMinimalModel()
                container = NSPersistentContainer(name: "ClipStack", managedObjectModel: model)
            }
        }
        
        self.persistentContainer = container
        
        // Configure persistent store
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Load persistent stores
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load Core Data stack: \(error)")
                // Don't crash the app, just continue without Core Data
                return
            }
        }
        
        // Configure view context
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Start auto-save
        startAutoSave()
    }
    
    /// Create a minimal Core Data model as fallback
    private static func createMinimalModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let clipItemEntity = NSEntityDescription()
        clipItemEntity.name = "ClipItemEntity"
        clipItemEntity.managedObjectClassName = "ClipItemEntity"
        
        // Add attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        contentAttribute.isOptional = false
        
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = false
        
        let sourceAppAttribute = NSAttributeDescription()
        sourceAppAttribute.name = "sourceApp"
        sourceAppAttribute.attributeType = .stringAttributeType
        sourceAppAttribute.isOptional = true
        
        let contentTypeAttribute = NSAttributeDescription()
        contentTypeAttribute.name = "contentType"
        contentTypeAttribute.attributeType = .stringAttributeType
        contentTypeAttribute.isOptional = false
        
        clipItemEntity.properties = [idAttribute, contentAttribute, timestampAttribute, sourceAppAttribute, contentTypeAttribute]
        model.entities = [clipItemEntity]
        
        return model
    }
    
    deinit {
        stopAutoSave()
    }
    
    // MARK: - Auto-Save
    
    /// Start auto-save timer
    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(
            withTimeInterval: autoSaveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.saveContext()
        }
    }
    
    /// Stop auto-save timer
    private func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    // MARK: - Save Operations
    
    /// Save the view context if it has changes
    func saveContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    /// Save context with error handling
    func saveContextWithError() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }
    
    // MARK: - ClipItem Operations
    
    /// Save a single ClipItem
    func saveItem(_ item: ClipItem) throws {
        _ = ClipItemEntity.create(from: item, in: viewContext)
        try saveContextWithError()
    }
    
    /// Save multiple ClipItems in batch
    func saveItems(_ items: [ClipItem]) throws {
        let context = backgroundContext
        
        context.performAndWait {
            for item in items {
                _ = ClipItemEntity.create(from: item, in: context)
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to batch save items: \(error)")
            }
        }
    }
    
    /// Load all ClipItems sorted by timestamp
    func loadItems() throws -> [ClipItem] {
        let request = ClipItemEntity.fetchAllSorted()
        let entities = try viewContext.fetch(request)
        return entities.compactMap { $0.toClipItem() }
    }
    
    /// Load items with a limit
    func loadItems(limit: Int) throws -> [ClipItem] {
        let request = ClipItemEntity.fetchAllSorted()
        request.fetchLimit = limit
        let entities = try viewContext.fetch(request)
        return entities.compactMap { $0.toClipItem() }
    }
    
    /// Load items by content type
    func loadItems(ofType type: ClipItem.ContentType) throws -> [ClipItem] {
        let request = ClipItemEntity.fetchByContentType(type)
        let entities = try viewContext.fetch(request)
        return entities.compactMap { $0.toClipItem() }
    }
    
    /// Load items from a specific source app
    func loadItems(fromApp app: String) throws -> [ClipItem] {
        let request = ClipItemEntity.fetchBySourceApp(app)
        let entities = try viewContext.fetch(request)
        return entities.compactMap { $0.toClipItem() }
    }
    
    // MARK: - Delete Operations
    
    /// Delete a single ClipItem by ID
    func deleteItem(withId id: UUID) throws {
        let request = ClipItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let entities = try viewContext.fetch(request)
        for entity in entities {
            viewContext.delete(entity)
        }
        
        try saveContextWithError()
    }
    
    /// Delete multiple ClipItems by IDs
    func deleteItems(withIds ids: [UUID]) throws {
        let context = backgroundContext
        
        try context.performAndWait {
            let request = ClipItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)
            
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
    }
    
    /// Delete all ClipItems
    func deleteAllItems() throws {
        let context = backgroundContext
        
        try context.performAndWait {
            let request = ClipItemEntity.fetchRequest()
            let entities = try context.fetch(request)
            
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
    }
    
    /// Delete items older than a specific date
    func deleteItems(olderThan date: Date) throws -> Int {
        let context = backgroundContext
        var deletedCount = 0
        
        try context.performAndWait {
            let request = ClipItemEntity.fetchOlderThan(date)
            let entities = try context.fetch(request)
            
            deletedCount = entities.count
            
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
        
        return deletedCount
    }
    
    // MARK: - Statistics
    
    /// Get total count of stored items
    func getItemCount() throws -> Int {
        let request = ClipItemEntity.fetchRequest()
        return try viewContext.count(for: request)
    }
    
    /// Get count of items by content type
    func getItemCount(ofType type: ClipItem.ContentType) throws -> Int {
        let request = ClipItemEntity.fetchByContentType(type)
        return try viewContext.count(for: request)
    }
    
    /// Get storage size estimate in bytes
    func getStorageSizeEstimate() throws -> Int64 {
        let items = try loadItems()
        var totalSize: Int64 = 0
        
        for item in items {
            totalSize += Int64(item.content.utf8.count)
            if let sourceApp = item.sourceApp {
                totalSize += Int64(sourceApp.utf8.count)
            }
        }
        
        return totalSize
    }
    
    // MARK: - Maintenance
    
    /// Clean up old items (older than specified days)
    func cleanupOldItems(olderThanDays days: Int) throws -> Int {
        let date = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return try deleteItems(olderThan: date)
    }
    
    /// Reset the entire database
    func resetDatabase() throws {
        try deleteAllItems()
        saveContext()
    }
}