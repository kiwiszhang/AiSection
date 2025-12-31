//
//  RecordingStore.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/27.
//

import UIKit
import CoreData

struct RecordingWaveformItemRequest {
    let duration:Double?
    let fileURL:String?
    let waveformData:Data?
    let createTime:Int64?
}

final class RecordingWaveformItemStore {
    static let shared = RecordingWaveformItemStore()
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// 新增RecordingWaveformItem
    func addRecordingWaveformItem(_ req: RecordingWaveformItemRequest) throws {
        let item = RecordingWaveformItem(context: context)
        item.id = UUID()
        item.createTime = req.createTime!
        item.duration = req.duration!
        item.fileURL = req.fileURL
        item.waveformData = req.waveformData
        try context.save()
    }
    
    /// 更新 RecordingWaveformItem
    func updateRecordingWaveformItem(_ item: RecordingWaveformItem) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 删除RecordingWaveformItem
    func delete(_ item: RecordingWaveformItem) throws {
        context.delete(item)
        try context.save()
    }
    
    /// 删除所有 RecordingWaveformItem
    func deleteAllRecordingWaveformItem() throws {
        let fetchRequest: NSFetchRequest<RecordingWaveformItem> = RecordingWaveformItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    /// 更新RecordingWaveformItem
    func updateRecordingWaveformItemRequest(_ req: RecordingWaveformItemRequest) throws {
        let fetchRequest: NSFetchRequest<RecordingWaveformItem> = RecordingWaveformItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createTime == %lld", req.createTime!)
        if let item = try context.fetch(fetchRequest).first {
            // 更新属性
            if let createTime = req.createTime {
                item.createTime = createTime
            }
            if let duration = req.duration {
                item.duration = duration
            }
            if let fileURL = req.fileURL {
                item.fileURL = fileURL
            }
            if let waveformData = req.waveformData {
                item.waveformData = waveformData
            }
            try context.save()
        } else {
            throw NSError(domain: "RecordingItem", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "未找到要更新的 RecordingItem，createTime=\(req.createTime!)"
            ])
        }
    }
    
    /// 查询所有 RecordingWaveformItem
    func fetchAllRecordingWaveformItem() throws -> [RecordingWaveformItem] {
        let fetchRequest: NSFetchRequest<RecordingWaveformItem> = RecordingWaveformItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)] // 可选日期倒序
        return try context.fetch(fetchRequest)
    }
    
    
}

extension Array where Element == Float {
    func toData() -> Data {
        withUnsafeBufferPointer { Data(buffer: $0) }
    }
}

extension Data {
    func toFloatArray() -> [Float] {
        let count = count / MemoryLayout<Float>.size
        return withUnsafeBytes {
            Array(
                UnsafeBufferPointer<Float>(
                    start: $0.bindMemory(to: Float.self).baseAddress!,
                    count: count
                )
            )
        }
    }
}

