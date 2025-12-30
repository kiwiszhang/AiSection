//
//  HomeConfigData.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

class HomeConfigData {
    static func getHomeMoreData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.share, itemIcon: Asset.moreShare.image)
        let item01 = PopItemModel(itemName: L10n.addToFavorites, itemIcon: Asset.moreFavorite.image)
        let item02 = PopItemModel(itemName: L10n.moveToFolder, itemIcon: Asset.moreMoveFloder.image)
        let item03 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item04 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item02,item03,item04]
    }
    
    static func getHomeMoreUnFavoriteData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.share, itemIcon: Asset.moreShare.image)
        let item01 = PopItemModel(itemName: L10n.removeFromFavorites, itemIcon: Asset.moreUnFavorite.image)
        let item02 = PopItemModel(itemName: L10n.moveToFolder, itemIcon: Asset.moreMoveFloder.image)
        let item03 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item04 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item02,item03,item04]
    }
    
    static func getHomeMoreShareData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.shareSummaryInPDF, itemIcon: Asset.shareSummaryPdf.image)
        let item01 = PopItemModel(itemName: L10n.shareSummaryInText, itemIcon: Asset.shareSummaryText.image)
        let item02 = PopItemModel(itemName: L10n.shareTranscriptInPDF, itemIcon: Asset.shareTranscriptPdf.image)
        let item03 = PopItemModel(itemName: L10n.shareTranscriptInText, itemIcon: Asset.shareTranscriptText.image)
        let item04 = PopItemModel(itemName: L10n.shareAudio, itemIcon: Asset.shareAudio.image)
        return [item00,item01,item02,item03,item04]
    }
    
    static func getMoveOutFolderData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.share, itemIcon: Asset.moreShare.image)
        let item01 = PopItemModel(itemName: L10n.addToFavorites, itemIcon: Asset.moreFavorite.image)
        let item111 = PopItemModel(itemName: L10n.removeFolder, itemIcon: Asset.removeFolder.image)
        let item02 = PopItemModel(itemName: L10n.moveToFolder, itemIcon: Asset.moreMoveFloder.image)
        let item03 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item04 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item111,item02,item03,item04]
    }
    
    static func getMoveOutFolderUnFavoriteData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.share, itemIcon: Asset.moreShare.image)
        let item01 = PopItemModel(itemName: L10n.removeFromFavorites, itemIcon: Asset.moreUnFavorite.image)
        let item111 = PopItemModel(itemName: L10n.removeFolder, itemIcon: Asset.removeFolder.image)
        let item02 = PopItemModel(itemName: L10n.moveToFolder, itemIcon: Asset.moreMoveFloder.image)
        let item03 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item04 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item111,item02,item03,item04]
    }
    static func getHomeFloderData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.addNote, itemIcon: Asset.floderAdd.image)
        let item01 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item02 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item02]
    }
    
    static func getFloderMoreData() -> [PopItemModel] {
        let item00 = PopItemModel(itemName: L10n.newFolder, itemIcon: Asset.moreNewFolder.image)
        let item01 = PopItemModel(itemName: L10n.moveToFolder, itemIcon: Asset.moreMoveFloder.image)
        let item02 = PopItemModel(itemName: L10n.rename, itemIcon: Asset.moreRename.image)
        let item03 = PopItemModel(itemName: L10n.delete, itemIcon: Asset.moreDelete.image)
        return [item00,item01,item02,item03]
    }
}
