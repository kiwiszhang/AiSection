//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData
import CryptoKit

struct RecordingItemRequest {
    let updateTime:Int64?
    let recordType:Int16?
    let handleType:Int16?
    let recordPath:String?
    let recordName:String?
    let recordFolder:String?
    let recordFolderId:String?
    let isFavorite:Bool?
    let createTime:Int64?
    
    var transcriptionData:Data?
    var translationData:Data?
    var summarizationData:Data?
    var informationData:Data?
    var chapterSummaryData:Data?
    
    var informationHtml:String?
    var summariztionHtml:String?
    var transcriptionHtml:String?
    
    var chapterSummaryJsonString:String?
    var summaryContentJsonString:String?
    var summaryTitle:String?
    var todoJsonString:String?

}

final class RecordingItemStore {
    static let shared = RecordingItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// 去重
    func removeDuplicateRecordingItemKeepLast() throws {
        let items = try fetchAllRecordingItem()
        var seen = Set<Int64>()
        for item in items {
            let createTime = item.createTime
            if seen.contains(createTime) {
                context.delete(item)
            } else {
                seen.insert(createTime)
            }
        }
        try context.save()
    }

    /// 新增RecordingItem
    func addRecordingItem(_ req: RecordingItemRequest) throws {
        let uuid = "\(String(describing: req.createTime))".stableUUID  // 根据 createTime 生成唯一 ID
        // 查询是否已有相同 ID 的 RecordingItem
        let fetchRequest: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        
        if let existing = try context.fetch(fetchRequest).first {
            // 已存在 → 更新
            existing.updateTime = Int64.min
            existing.recordType = req.recordType!
            existing.handleType = req.handleType ?? 0
            existing.recordPath = req.recordPath
            existing.recordName = req.recordName
            existing.recordFolder = req.recordFolder
            existing.recordFolderId = req.recordFolderId
            existing.isFavorite = req.isFavorite ?? false
            existing.transcriptionData = req.transcriptionData
            existing.translationData = req.translationData
            existing.summarizationData = req.summarizationData
            existing.informationData = req.informationData
            existing.chapterSummaryData = req.chapterSummaryData

            existing.informationHtml = req.informationHtml
            existing.summariztionHtml = req.summariztionHtml
            existing.transcriptionHtml = req.transcriptionHtml
            
            existing.todoJsonString = req.todoJsonString
            existing.summaryTitle = req.summaryTitle
            existing.summaryContentJsonString = req.summaryContentJsonString
            existing.chapterSummaryJsonString = req.chapterSummaryJsonString

            existing.createTime = req.createTime ?? Int64.min
        } else {
            // 不存在 → 插入
            let item = RecordingItem(context: context)
            item.id = uuid
            item.updateTime = req.updateTime ?? Int64.min
            item.recordType = req.recordType!
            item.handleType = req.handleType ?? 0
            item.recordPath = req.recordPath
            item.recordName = req.recordName
            item.recordFolder = req.recordFolder
            item.recordFolderId = req.recordFolderId
            item.isFavorite = req.isFavorite ?? false
            item.transcriptionData = req.transcriptionData
            item.translationData = req.translationData
            item.summarizationData = req.summarizationData
            item.informationData = req.informationData
            item.chapterSummaryData = req.chapterSummaryData

            item.informationHtml = req.informationHtml
            item.summariztionHtml = req.summariztionHtml
            item.transcriptionHtml = req.transcriptionHtml

            item.chapterSummaryJsonString = req.chapterSummaryJsonString
            item.summaryContentJsonString = req.summaryContentJsonString
            item.summaryTitle = req.summaryTitle
            item.todoJsonString = req.todoJsonString

            item.createTime = req.createTime ?? Int64.min
        }
        
        try context.save()
    }
    
    /// 新增RecordingItem
//    func addRecordingItem(_ req: RecordingItemRequest) throws {
//        let item = RecordingItem(context: context)
//        item.id = UUID()
//        item.updateTime = req.updateTime!
//        item.createTime = req.createTime!
//        item.recordType = req.recordType!
//        item.handleType = req.handleType!
//        item.recordPath = req.recordPath
//        item.recordFolder = req.recordFolder
//        item.recordFolderId = req.recordFolderId!
//        item.isFavorite = req.isFavorite!
//        item.recordName = req.recordName
//        item.transcriptionData = req.transcriptionData
//        item.chapterSummaryData = req.chapterSummaryData
//        item.informationData = req.informationData
//        item.summarizationData = req.summarizationData
//        item.translationData = req.translationData
//        try context.save()
//    }
    
    /// 更新 RecordingItem
    func updateRecordingItem(_ item: RecordingItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除RecordingItem
    func delete(_ item: RecordingItem) throws {
        UtitilTools.deleteTOSObject(fileName: "Recording/\(item.recordPath!)") { task in
            if ((task.error == nil)) {
                MyLog("Delete object success.");
            } else {
                MyLog("Delete object failed, error: \(String(describing: task.error))");
            }
        }
        UtitilTools.deleteRecording(relativePath: "Recording/\(item.recordPath!)")
        try TranscriptionItemStore.shared.deleteByCreateTimePredicate(createTime: item.createTime)
        try ChatInfoItemStore.shared.deleteByCreateTimePredicate(createTime: item.createTime)
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
            if let handleType = req.handleType {
                item.handleType = handleType
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
            if let transcriptionData = req.transcriptionData {
                item.transcriptionData = transcriptionData
            }
            if let chapterSummaryData = req.chapterSummaryData {
                item.chapterSummaryData = chapterSummaryData
            }
            if let informationData = req.informationData {
                item.informationData = informationData
            }
            if let summarizationData = req.summarizationData {
                item.summarizationData = summarizationData
            }
            if let translationData = req.translationData {
                item.translationData = translationData
            }
            if let transcriptionHtml = req.transcriptionHtml {
                item.transcriptionHtml = transcriptionHtml
            }
            if let summariztionHtml = req.summariztionHtml {
                item.summariztionHtml = summariztionHtml
            }
            if let informationHtml = req.informationHtml {
                item.informationHtml = informationHtml
            }
            if let chapterSummaryJsonString = req.chapterSummaryJsonString {
                item.chapterSummaryJsonString = chapterSummaryJsonString
            }
            if let summaryContentJsonString = req.summaryContentJsonString {
                item.summaryContentJsonString = summaryContentJsonString
            }
            if let summaryTitle = req.summaryTitle {
                item.summaryTitle = summaryTitle
            }
            if let todoJsonString = req.todoJsonString {
                item.todoJsonString = todoJsonString
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
        var predicates: [NSPredicate] = []
        if isFavorite {
            predicates.append(
                NSPredicate(format: "isFavorite == %@", NSNumber(value: isFavorite))
            )
        }
        // 🔥 排除条件
//        predicates.append(
//            NSPredicate(format: "recordName != %@", "isDemo")
//        )
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    /// 根据recordFolderId查询有多少个文件
    func fileCount(in recordFolderId: String) -> Int {
        let request: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        request.predicate = NSPredicate(
            format: "recordFolderId == %@",
            recordFolderId
        )
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
    
    /// 根据recordFolderId查询
    func fetchByFolderId(_ folderId: String) throws -> [RecordingItem] {
        let req: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        req.predicate = NSPredicate(
            format: "recordFolderId == %@",
            folderId
        )
        req.sortDescriptors = [
            NSSortDescriptor(key: "updateTime", ascending: false)
        ]
        return try context.fetch(req)
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
    
    /// recordName字段模糊查询
    func searchByKeywordWithOutFavorite(_ keyword: String) throws -> [RecordingItem] {
        let req: NSFetchRequest<RecordingItem> = RecordingItem.fetchRequest()
        var predicates: [NSPredicate] = []
        
        predicates.append(
            NSPredicate(format: "isFavorite != %@",  NSNumber(value: true))
        )
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


extension String {
    var stableUUID: UUID {
        let hash = self.data(using: .utf8)!.sha256()
        return UUID(uuid: (
            hash[0], hash[1], hash[2], hash[3],
            hash[4], hash[5], hash[6], hash[7],
            hash[8], hash[9], hash[10], hash[11],
            hash[12], hash[13], hash[14], hash[15]
        ))
    }
}

extension Data {
    func sha256() -> Data {
        let digest = SHA256.hash(data: self)
        return Data(digest)
    }
}

extension String {
    func sha256() -> Data {
        return Data(self.utf8).sha256()
    }
}
