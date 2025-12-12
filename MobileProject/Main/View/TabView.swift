//
//  TabView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol TabViewDelegate: AnyObject {
    func tabClickItemIndex(_ index: Int)
}

class TabView: SuperView {
    weak var delegate: TabViewDelegate?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal          // 横向
        layout.itemSize = CGSize(width: 105.w, height: 40.h)
        layout.minimumLineSpacing = 14.w
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16.w, bottom: 0, right: 16.w)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        return cv
    }()
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)

    lazy var items = [L10n.allNotes,L10n.folder,L10n.favorites]
    
    override func setUpUI() {
        addChildView([collectionView])
        collectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}


extension TabView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Cell 个数
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    // Cell 内容
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell",
                                                      for: indexPath) as! MyCell
        cell.setString(item: items[indexPath.item])
        if indexPath == selectedIndex {
            cell.setSelectedStyle()
        } else {
            cell.setNormalStyle()
        }
        return cell
    }

    // 点击事件
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        MyLog("点击了第 \(indexPath.item) 项")
        selectedIndex = indexPath
        collectionView.reloadData()
        delegate?.tabClickItemIndex(indexPath.row)
    }
}



class MyCell: SuperCollectionViewCell {

    private lazy var bgImageView: UIImageView = {
        let img = UIImageView(image:Asset.selected.image)
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    lazy var label = UILabel().color(.white).text(L10n.allNotes).cornerRadius(12.h).hnFont(size: 14.h, weight: .medium).centerAligned().backgroundColor(.clear)
    
    override func setUpUI() {
        
        contentView.addSubview(bgImageView)
        contentView.addSubview(label)

        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func setSelectedStyle() {
        bgImageView.image(Asset.selected.image).cornerRadius(12.h)
        label.color(.white).cornerRadius(12.h)
    }

    func setNormalStyle() {
        bgImageView.image = nil
        bgImageView.backgroundColor(kkColorFromHex("DEE3EB")).cornerRadius(12.h)
        label.color(kkColorFromHex(kkMainTextColor)).cornerRadius(12.h)
        
    }
    
    func setString(item:String){
        label.text(item)
    }

}

