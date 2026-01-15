//
//  ChatViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/7.
//

import UIKit
import AVFAudio
import Speech
import AVFoundation

class ChatHistoryViewController: SuperViewController {

    private lazy var itemList:[ChatInfoItem] = []
    private lazy var selectedItemList:[ChatInfoItem] = []
    var selectedIndexPath: IndexPath?

    var recordingItem:RecordingItem? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(ChatInfoItemHistoryCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeightAutomaticDimension().estimatedRowHeight(80.h).showsH(false).showsV(false)
    }()
    private lazy var topView = ChatHistoryNavTopView().backgroundColor(kkColorFromHex("EDF4FF"))

    init(recordingItem:RecordingItem) {
        super.init(nibName: nil, bundle: nil)
        self.recordingItem = recordingItem
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)

       
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex("EDF4FF")
        // Do any additional setup after loading the view.
    }
    
    override func setUpUI() {
        
        view.addChildView([tableView,topView])
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(88.h)
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalToSuperview()
        }

    }
    
    override func getData() {
        topView.delegate = self
        
        itemList = try! ChatInfoItemStore.shared.fetchAllChatInfoItemWithRecordCreateTime(createTime: recordingItem!.createTime)
        tableView.reloadData()

    }
}

// MARK: -  =======================ChatHistoryNavTopViewDelegate========================
extension ChatHistoryViewController:ChatHistoryNavTopViewDelegate {
    func chatHistoryBackClick(){
        self.navigationController?.popViewController(animated: true)
    }
    func chatHistoryMoreClick(){
        MyLog("chatHistoryMoreClick")
    }
}
//MARK: ----------TableViewDelegateDataSource-----------
extension ChatHistoryViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return itemList.count
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemList[indexPath.row]
        let cell = tableView.dequeueCell(ChatInfoItemHistoryCell.self, for: indexPath)
        cell.selectionStyle = .none
//        cell.configure(with: model)
        let isTapSelected = (indexPath == selectedIndexPath)
        let isSelected = selectedItemList.contains { $0.objectID == model.objectID }
        cell.configure(with: model,isSelected:isSelected,isTapSelected:isTapSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
    
        let model = itemList[indexPath.row]
        if let index = selectedItemList.firstIndex(of: model) {
            selectedItemList.remove(at: index)
        } else {
            selectedItemList.append(model)
        }
//        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return head
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let foot = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return foot
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.01
    }
}

class ChatInfoItemHistoryCell: SuperTableViewCell {
    private var itemModel:ChatInfoItem? = nil
    private lazy var bgView = UILabel().backgroundColor(.clear)
    private lazy var contentBg = UILabel()
    private lazy var contentL = CopyableLabel().textNoAdjust("").hnFont(size: 14.h, weight: .regular).color(.white).lines(2)
//    private lazy var timeL = UILabel().text("").hnFont(size: 10.h, weight: .regular).color(kkColorFromHex(kkSubTextColor))
    private lazy var dateV = DetailItemView()
    private lazy var timeL = DetailItemView()

    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        bgView.addChildView([contentBg])
        contentBg.addChildView([contentL,dateV,timeL])
        contentView.backgroundColor(.clear)
        
        let maxBubbleWidth = kkScreenWidth - 48.w

        bgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        contentBg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-8.h)
            make.left.equalToSuperview().offset(24.w)
            make.right.equalToSuperview().offset(-24.w)
//            // 关键：最大宽度限制
//            make.width.lessThanOrEqualTo(maxBubbleWidth)
//            // 左右对齐其中一个（根据消息方向控制）
//            leadingConstraint = make.leading.equalToSuperview().offset(24.w).constraint
//            trailingConstraint = make.trailing.equalToSuperview().offset(-24.w).constraint
        }
        
        contentL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.w)
            make.right.equalToSuperview().offset(-15.w)
//            make.bottom.equalToSuperview().offset(-10.h)
            make.top.equalToSuperview().offset(10.h)
        }
        dateV.snp.makeConstraints { make in
            make.left.equalTo(contentL)
            make.width.equalTo(74.w)
            make.top.equalTo(contentL.snp.bottom).offset(8.h)
            make.bottom.equalToSuperview().offset(-20.h)
        }
        timeL.snp.makeConstraints { make in
            make.left.equalTo(dateV.snp.right).offset(14.w)
            make.bottom.equalToSuperview().offset(-20.h)
            make.top.equalTo(contentL.snp.bottom).offset(8.h)
        }
        
        contentL.preferredMaxLayoutWidth = maxBubbleWidth
        contentL.setContentHuggingPriority(.required, for: .horizontal)
        contentL.setContentCompressionResistancePriority(.required, for: .horizontal)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleCopyLongPress(_:))
        )
        self.isUserInteractionEnabled = true
        bgView.isUserInteractionEnabled = true
        contentBg.isUserInteractionEnabled = true
        contentL.isUserInteractionEnabled = true
        contentL.addGestureRecognizer(longPress)
        longPress.cancelsTouchesInView = false
    }
    
    @objc private func handleCopyLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let label = gesture.view as? UILabel,
              let text = label.text,
              !text.isEmpty else { return }

        label.becomeFirstResponder()

        let menu = UIMenuController.shared
        menu.setTargetRect(label.bounds, in: label)
        menu.setMenuVisible(true, animated: true)
    }

    
    func configure(with item: ChatInfoItem,isSelected:Bool,isTapSelected:Bool) {
        itemModel = item
        contentL.attributedText = makeAttributedText((itemModel?.content)!)

        if isSelected {
            contentL.lines(0)
            contentL.lineBreakMode = .byWordWrapping
        }else{
            contentL.lineBreakMode = .byTruncatingTail
            contentL.lines(2)
        }
        let result = UtitilTools.formatTimestamp(item.createTime)
        dateV.updateData(icon: Asset.canlande.image, title: result.date)
        timeL.updateData(icon: Asset.timeShow.image, title: result.time)
//        if itemModel?.chatType == 0 {
//            contentBg.cornerRadius(14.h, corners: [.topLeft,.bottomLeft,.bottomRight]).backgroundColor(kkColorFromHex(kkMainColor)).rightAligned()
//            contentL.color(.white)
//            leadingConstraint?.isActive = false
//            trailingConstraint?.isActive = true
//
//        }else{
//            contentBg.cornerRadius(14.h, corners: [.topRight,.bottomLeft,.bottomRight]).backgroundColor(kkColorFromHex(kkHomeBgColor)).leftAligned()
//            contentL.color(kkColorFromHex(kkMainTextColor))
//            leadingConstraint?.isActive = true
//            trailingConstraint?.isActive = false
//
//        }
        
        contentBg.cornerRadius(14.h).backgroundColor(.white).leftAligned()
        contentL.color(kkColorFromHex(kkMainTextColor)).backgroundColor(.clear)
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = false
        
        if isTapSelected {
            contentBg.border(width: 1, color: kkColorFromHex(kkMainColor))
        }else{
            contentBg.border(width: 1, color: .clear)
        }
    }

    private func makeAttributedText(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.lineBreakMode = .byWordWrapping

        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.h),
                .paragraphStyle: paragraph
            ]
        )
    }
}
