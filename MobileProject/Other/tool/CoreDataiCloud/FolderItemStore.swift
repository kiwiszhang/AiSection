//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData

struct FolderItemRequest {
    let folderName:String?
    let recordFolderId:String?
    let createTime:Int64?
}

final class FolderItemStore {
    static let shared = FolderItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// 新增FolderItem
    func addFolderItem(_ req: FolderItemRequest) throws {
        let item = FolderItem(context: context)
        item.id = UUID()
        item.createTime = req.createTime!
        item.folderName = req.folderName
        item.recordFolderId = req.recordFolderId!
        try context.save()
    }
    
    /// 更新 FolderItem
    func updateFolderItem(_ item: FolderItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除FolderItem
    func delete(_ item: FolderItem) throws {
        context.delete(item)
        try context.save()
    }
    

    /// 删除所有 FolderItem
    func deleteAllFolderItems() throws {
        let fetchRequest: NSFetchRequest<FolderItem> = FolderItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    /// 更新FolderItem
    func updateFolderItemWithRequest(_ req: FolderItemRequest) throws {
        let fetchRequest: NSFetchRequest<FolderItem> = FolderItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createTime == %lld", req.createTime!)
        if let item = try context.fetch(fetchRequest).first {
            // 更新属性
            if let createTime = req.createTime {
                item.createTime = createTime
            }
            if let folderName = req.folderName {
                item.folderName = folderName
            }
            if let recordFolderId = req.recordFolderId {
                item.recordFolderId = recordFolderId
            }
            try context.save()
        } else {
            throw NSError(domain: "FolderItem", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "未找到要更新的 FolderItem，createTime=\(req.createTime!)"
            ])
        }
    }
    
    /// 查询所有 FolderItem
    func fetchAllFolderItem() throws -> [FolderItem] {
        let fetchRequest: NSFetchRequest<FolderItem> = FolderItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// folderName字段模糊查询
    func searchByKeyword(_ keyword: String) throws -> [FolderItem] {
        let req: NSFetchRequest<FolderItem> = FolderItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "folderName CONTAINS[cd] %@", keyword)
        )
        // 🔥 排除条件
        predicates.append(
            NSPredicate(format: "folderName != %@", "isDemo")
        )
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        req.sortDescriptors = [
            NSSortDescriptor(key: "createTime", ascending: false)
        ]
        return try context.fetch(req)
    }
}
