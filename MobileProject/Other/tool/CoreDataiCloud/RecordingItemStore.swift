//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData

struct RecordingItemRequest {
    let updateTime:Int64?
    let recordType:Int16?
    let recordPath:String?
    let recordName:String?
    let recordFolder:String?
    let recordFolderId:Int16?
    let isFavorite:Bool?
    let createTime:Int64?
}

final class RecordingItemStore {
    static let shared = RecordingItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// 新增RecordingItem
    func addRecordingItem(_ req: RecordingItemRequest) throws {
        let item = RecordingItem(context: context)
        item.id = UUID()
        item.updateTime = req.updateTime!
        item.createTime = req.createTime!
        item.recordType = req.recordType!
        item.recordPath = req.recordPath
        item.recordFolder = req.recordFolder
        item.recordFolderId = req.recordFolderId!
        item.isFavorite = req.isFavorite!
        item.recordName = req.recordName
        try context.save()
    }
    
    /// 更新 RecordingItem
    func updateRecordingItem(_ item: RecordingItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除RecordingItem
    func delete(_ item: RecordingItem) throws {
        context.delete(item)
        try context.save()
    }
    
    /// 删除所有 RecordingItem
    func deleteAllRecordingItems() throws {
        let fetchRequest: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    /// 更新RecordingItem
    func updateRecordingItemWithRequest(_ req: RecordingItemRequest) throws {
        let fetchRequest: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createTime == %lld", req.createTime!)
        if let item = try context.fetch(fetchRequest).first {
            // 更新属性
            if let updateTime = req.updateTime {
                item.updateTime = updateTime
            }
            if let createTime = req.createTime {
                item.createTime = createTime
            }
            if let recordType = req.recordType {
                item.recordType = recordType
            }
            if let recordPath = req.recordPath {
                item.recordPath = recordPath
            }
            if let recordFolder = req.recordFolder {
                item.recordFolder = recordFolder
            }
            if let recordFolderId = req.recordFolderId {
                item.recordFolderId = recordFolderId
            }
            if let isFavorite = req.isFavorite {
                item.isFavorite = isFavorite
            }
            try context.save()
        } else {
            throw NSError(domain: "RecordingItem", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "未找到要更新的 RecordingItem，createTime=\(req.createTime!)"
            ])
        }
    }
    
    /// 查询所有 RecordingItem
    func fetchAllRecordingItem(isFavorite: Bool = false) throws -> [RecordingItem] {
        let fetchRequest: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        if isFavorite {
            fetchRequest.predicate = NSPredicate(
                    format: "isFavorite == %@",
                    NSNumber(value: isFavorite)
                )
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// 根据recordFolderId查询有多少个文件
    func fileCount(in recordFolderId: Int16) -> Int {
        let request: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        request.predicate = NSPredicate(
            format: "recordFolderId == %d",
            recordFolderId
        )
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
    /// recordName字段模糊查询
    func searchByKeyword(_ keyword: String,in isFavorite: Bool = false) throws -> [RecordingItem] {
        let req: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        var predicates: [NSPredicate] = []
        if isFavorite {
            predicates.append(
                NSPredicate(format: "isFavorite == %@", NSNumber(value: isFavorite))
            )
        }
        predicates.append(
            NSPredicate(format: "recordName CONTAINS[cd] %@", keyword)
        )
        
        // 🔥 排除条件
        predicates.append(
            NSPredicate(format: "recordName != %@", "isDemo")
        )
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        req.sortDescriptors = [
            NSSortDescriptor(key: "updateTime", ascending: false)
        ]
        return try context.fetch(req)
    }

    
    
}
