//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData

struct TranscriptionItemRequest {
    let channel_id:Int16?
    let content:String?
    let createTime:Int64?
    let recordCreateTime:Int64?
    let end_time:Double?
    let lang:String?
    let paragraph_id:Int16?
    let sentence_id:Int16?
    let speakerName:String?
    let speakerType:Int16?
    let start_time:Double?
    let words:String?
}

final class TranscriptionItemStore {
    static let shared = TranscriptionItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func addTranscriptionItems(_ items: [TranscriptionItemRequest]) throws {
        guard !items.isEmpty else { return }

        let context = PersistenceController.shared.newBackgroundContext()

        try context.performAndWait {
            for item in items {
                let entity = TranscriptionItem(context: context)
                entity.channel_id = item.channel_id ?? 0
                entity.content = item.content
                entity.createTime = item.createTime ?? Int64(Date().timeIntervalSince1970)
                entity.recordCreateTime = item.recordCreateTime ?? 0
                entity.start_time = item.start_time ?? 0
                entity.end_time = item.end_time ?? 0
                entity.speakerName = item.speakerName
                entity.speakerType = item.speakerType ?? 0
                entity.lang = item.lang
                entity.words = item.words
            }
            try context.save()
        }
    }
    /// 新增TranscriptionItem
    func addTranscriptionItem(_ req: TranscriptionItemRequest) throws {
        let item = TranscriptionItem(context: context)
        item.id = UUID()
        item.channel_id = req.channel_id ?? 0
        item.createTime = req.createTime!
        item.recordCreateTime = req.recordCreateTime!
        item.content = req.content!
        item.end_time = req.end_time ?? 0
        item.lang = req.lang!
        item.paragraph_id = req.paragraph_id ?? 0
        item.speakerName = req.speakerName!
        item.speakerType = req.speakerType!
        item.start_time = req.start_time ?? 0
        item.words = req.words!
        try context.save()
    }
    
    /// 更新 TranscriptionItem
    func updateTranscriptionItem(_ item: TranscriptionItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除TranscriptionItem
    func delete(_ item: TranscriptionItem) throws {
        context.delete(item)
        try context.save()
    }
    
    /// 根据createTime删除TranscriptionItem
    func deleteByCreateTimePredicate(createTime:Int64) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> =
            TranscriptionItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "recordCreateTime != %@",
            NSNumber(value: createTime)
        )
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []
        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: objectIDs
        ]
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: changes,
            into: [context]
        )
    }


    /// 删除所有 TranscriptionItem
    func deleteAllTranscriptionItems() throws {
        let fetchRequest: NSFetchRequest<TranscriptionItem> = TranscriptionItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    /// 更新TranscriptionItem
    func updateTranscriptionItemWithRequest(_ req: TranscriptionItemRequest) throws {
        let fetchRequest: NSFetchRequest<TranscriptionItem> = TranscriptionItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createTime == %lld", req.createTime!)
        if let item = try context.fetch(fetchRequest).first {
            // 更新属性
            if let createTime = req.createTime {
                item.createTime = createTime
            }
            if let recordCreateTime = req.recordCreateTime {
                item.recordCreateTime = recordCreateTime
            }
            if let channel_id = req.channel_id {
                item.channel_id = channel_id
            }
            if let content = req.content {
                item.content = content
            }
            if let end_time = req.end_time {
                item.end_time = end_time
            }
            if let lang = req.lang {
                item.lang = lang
            }
            if let paragraph_id = req.paragraph_id {
                item.paragraph_id = paragraph_id
            }
            if let sentence_id = req.sentence_id {
                item.sentence_id = sentence_id
            }
            if let speakerName = req.speakerName {
                item.speakerName = speakerName
            }
            if let speakerType = req.speakerType {
                item.speakerType = speakerType
            }
            if let start_time = req.start_time {
                item.start_time = start_time
            }
            if let words = req.words {
                item.words = words
            }
            try context.save()
        } else {
            throw NSError(domain: "TranscriptionItem", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "未找到要更新的 TranscriptionItem，createTime=\(req.createTime!)"
            ])
        }
    }
    
    /// 查询所有 TranscriptionItem
    func fetchAllTranscriptionItem() throws -> [TranscriptionItem] {
        let fetchRequest: NSFetchRequest<TranscriptionItem> = TranscriptionItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "createTime != %@", NSNumber(value: Int64.min))
        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// 查询所有 TranscriptionItem
    func fetchTranscriptionItemWithRecordCreateTime(createTime:Int64) throws -> [TranscriptionItem] {
        let fetchRequest: NSFetchRequest<TranscriptionItem> = TranscriptionItem.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(
            NSPredicate(format: "recordCreateTime == %@", NSNumber(value: createTime))
        )
//        predicates.append(
//            NSPredicate(format: "chatType == %@", NSNumber(value: chatType))
//        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start_time", ascending: true)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
}

extension TranscriptionItemStore {

    
}
