//
//  ClipItemEntity.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Foundation
import CoreData

/// Core Data entity representing a clipboard item
@objc(ClipItemEntity)
public class ClipItemEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var timestamp: Date
    @NSManaged public var sourceApp: String?
    @NSManaged public var contentType: String
    
    /// Convert ClipItemEntity to ClipItem model
    func toClipItem() -> ClipItem? {
        guard let type = ClipItem.ContentType(rawValue: contentType) else {
            return nil
        }
        
        return ClipItem(
            id: id,
            content: content,
            timestamp: timestamp,
            sourceApp: sourceApp,
            contentType: type
        )
    }
    
    /// Update entity from ClipItem model
    func update(from item: ClipItem) {
        self.id = item.id
        self.content = item.content
        self.timestamp = item.timestamp
        self.sourceApp = item.sourceApp
        self.contentType = item.contentType.rawValue
    }
    
    /// Create a new ClipItemEntity from ClipItem
    static func create(from item: ClipItem, in context: NSManagedObjectContext) -> ClipItemEntity {
        let entity = ClipItemEntity(context: context)
        entity.update(from: item)
        return entity
    }
}

// MARK: - Fetch Request

extension ClipItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipItemEntity> {
        return NSFetchRequest<ClipItemEntity>(entityName: "ClipItemEntity")
    }
    
    /// Fetch all items sorted by timestamp (newest first)
    static func fetchAllSorted() -> NSFetchRequest<ClipItemEntity> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
    /// Fetch items with a specific content type
    static func fetchByContentType(_ type: ClipItem.ContentType) -> NSFetchRequest<ClipItemEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "contentType == %@", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
    /// Fetch items from a specific source app
    static func fetchBySourceApp(_ app: String) -> NSFetchRequest<ClipItemEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "sourceApp == %@", app)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
    /// Fetch items older than a specific date
    static func fetchOlderThan(_ date: Date) -> NSFetchRequest<ClipItemEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@", date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
}