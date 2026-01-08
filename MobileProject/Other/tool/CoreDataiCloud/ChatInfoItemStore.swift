//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData

struct ChatInfoItemRequest {
    let chatType:Int16?
    let content:String?
    let createTime:Int64?
    let recordCreateTime:Int64?
    let responseId:String?
}

final class ChatInfoItemStore {
    static let shared = ChatInfoItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// 新增ChatInfoItem
    func addChatInfoItem(_ req: ChatInfoItemRequest) throws {
        let item = ChatInfoItem(context: context)
        item.id = UUID()
        item.chatType = req.chatType!
        item.createTime = req.createTime!
        item.recordCreateTime = req.recordCreateTime!
        item.content = req.content!
        item.responseId = req.responseId!
        try context.save()
    }
    
    /// 更新 ChatInfoItem
    func updateChatInfoItem(_ item: ChatInfoItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除ChatInfoItem
    func delete(_ item: ChatInfoItem) throws {
        context.delete(item)
        try context.save()
    }
    

    /// 删除所有 ChatInfoItem
    func deleteAllChatInfoItems() throws {
        let fetchRequest: NSFetchRequest<ChatInfoItem> = ChatInfoItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    /// 更新ChatInfoItem
    func updateChatInfoItemWithRequest(_ req: ChatInfoItemRequest) throws {
        let fetchRequest: NSFetchRequest<ChatInfoItem> = ChatInfoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createTime == %lld", req.createTime!)
        if let item = try context.fetch(fetchRequest).first {
            // 更新属性
            if let createTime = req.createTime {
                item.createTime = createTime
            }
            if let recordCreateTime = req.recordCreateTime {
                item.recordCreateTime = recordCreateTime
            }
            if let chatType = req.chatType {
                item.chatType = chatType
            }
            if let content = req.content {
                item.content = content
            }
            if let responseId = req.responseId {
                item.responseId = responseId
            }
            try context.save()
        } else {
            throw NSError(domain: "ChatInfoItem", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "未找到要更新的 ChatInfoItem，createTime=\(req.createTime!)"
            ])
        }
    }
    
    /// 查询所有 ChatInfoItem
    func fetchAllChatInfoItem() throws -> [ChatInfoItem] {
        let fetchRequest: NSFetchRequest<ChatInfoItem> = ChatInfoItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "createTime != %@", NSNumber(value: Int64.min))
        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// 查询所有 ChatInfoItem
    func fetchAllChatInfoItemWithRecordCreateTime(createTime:Int64) throws -> [ChatInfoItem] {
        let fetchRequest: NSFetchRequest<ChatInfoItem> = ChatInfoItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "recordCreateTime == %@", NSNumber(value: createTime))
        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: true)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// 查询所有 ChatInfoItem
    func fetchChatInfoItemWithRecordCreateTimeAndChatType(createTime:Int64,chatType:Int) throws -> [ChatInfoItem] {
        let fetchRequest: NSFetchRequest<ChatInfoItem> = ChatInfoItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "recordCreateTime == %@", NSNumber(value: createTime))
        )
        predicates.append(
            NSPredicate(format: "chatType == %@", NSNumber(value: chatType))
        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: true)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
}
