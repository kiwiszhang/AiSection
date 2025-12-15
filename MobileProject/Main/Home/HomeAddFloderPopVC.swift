//
//  HomeFloderPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/15.
//

import UIKit

class HomeAddFloderPopVC: SuperViewController {
    var dismissAction: (() -> Void)?
    private lazy var barView = PopTopView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setUpUI() {
        view.addChildView([barView])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("FFFFFF"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.addFolder)
    }
    
}


// MARK: -  =======================PopTopViewDelegate========================
extension HomeAddFloderPopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    
    func clickSearch() {
        MyLog("clickSearch")
    }
}


