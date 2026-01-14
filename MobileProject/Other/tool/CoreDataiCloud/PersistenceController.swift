//
//  PersistenceController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/15.
//




let iCloudContainerID = "iCloud.com.yuehai.kiwiDev"

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "AISectionCoreDataICloud") // 与 .xcdatamodeld 名称一致

        guard let desc = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store description found.")
        }

        if inMemory {
            desc.url = URL(fileURLWithPath: "/dev/null")
        }

        // 打开历史记录 & 远端变更通知，提升同步可靠性
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // 绑定到你的 iCloud 容器
        desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: iCloudContainerID
        )

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Load store error: \(error)")
            }
        }
        
        // 监听 CloudKit 同步通知
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(cloudKitDidUpdate),
//            name: .NSPersistentStoreRemoteChange,
//            object: container.persistentStoreCoordinator
//        )

        // 合并后台改动到主上下文，便于 UI 自动刷新
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
