//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

struct ToolsModel {
    var title: String = ""
    var subTitle: String = ""
    var imageIcon: UIImage
    var toolsUrl: String = ""
}

class MeOtherToolsPopVC: SuperViewController {

    var dismissAction: (() -> Void)?
    private var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    private lazy var itemList:[ToolsModel] = []
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(ToolsItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(96.h).showsH(false).showsV(false)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(kkColorFromHex("F0F5FB"))
    }

    override func setUpUI() {
        view.addChildView([barView,tableView])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
            make.bottom.equalToSuperview().offset(-140.h)
        }
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("F0F5FB"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.otherTools)
        barView.delegate = self
        
        itemList = HomeConfigData.getToolsData()
        
        tableView.reloadData()
    }

}

// MARK: -  =======================PopTopViewDelegate========================
extension MeOtherToolsPopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    func refreshSearchDataPop(updatedText: String){
    }
    
    func refreshSearchNoDataPop(){
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension MeOtherToolsPopVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ToolsItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return head
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let foot = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return foot
    }
}

class ToolsItemCell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.meArrow.image).enable(true).onTap { [self] in
    }
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 16.h, weight: .medium)
    private lazy var subTitleL = UILabel().text("0").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,subTitleL])
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalTo(84.h)
            make.top.equalToSuperview().offset(12.h)
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(50.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(16.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.top.equalTo(iconImageV.snp.top)
            make.height.equalTo(19.h)
        }
        
        subTitleL.snp.makeConstraints { make in
            make.left.equalTo(titleL.snp.left).offset(0.w)
            make.right.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(5.h)
            make.height.equalTo(15.h)
        }

    }
    
    func configure(with item: ToolsModel) {
        iconImageV.image(item.imageIcon)
        titleL.text(item.title)
        subTitleL.text(item.subTitle)
    }
}
