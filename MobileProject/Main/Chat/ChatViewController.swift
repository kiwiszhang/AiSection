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

class ChatViewController: SuperViewController {

    private var bottomViewBottomConstraint: Constraint?
    private lazy var itemList:[ChatInfoItem] = []
    var recordingItem:RecordingItem? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(ChatInfoItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeightAutomaticDimension().estimatedRowHeight(80.h).showsH(false).showsV(false)
    }()
    private lazy var topView = ChatNavTopView()
    private lazy var tableHeaderView = ChatTableHeaderView().backgroundColor(.white)
    private lazy var bottomView = DetailBottomView()

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        bottomViewBottomConstraint?.update(offset: -keyboardFrame.height)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        bottomViewBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("语音识别授权成功")
            default:
                print("语音识别未授权")
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("麦克风授权成功")
            } else {
                print("麦克风未授权")
            }
        }

    }
    
    override func setUpUI() {
        
        view.addChildView([tableView,topView,bottomView])
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(88.h)
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        tableHeaderView.frame = CGRect(x: 0, y: 0,
                                       width: kkScreenWidth,
                                       height: 450.h)
        tableView.tableHeaderView = tableHeaderView
        
//        bottomView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(100.h)
//            make.bottom.equalToSuperview()
//        }
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(100.h)
            bottomViewBottomConstraint = make.bottom.equalToSuperview().constraint
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
//            make.top.equalTo(topView.snp.bottom)
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        tableView.keyboardDismissMode = .interactive


    }
    
    override func getData() {
        bottomView.delegate = self
        itemList = try! ChatInfoItemStore.shared.fetchAllChatInfoItemWithRecordCreateTime(createTime: recordingItem!.createTime)
        tableView.reloadData()
        tableHeaderView.updateData(item: recordingItem!)
    }
}

// MARK: -  =======================DetailBottomViewDelegate========================
extension ChatViewController:DetailBottomViewDelegate {
    func refreshDetailBottomData(updatedText:String){
        MyLog(updatedText)
    }
    func refreshDetailBottomNoData(){
        MyLog("refreshDetailBottomNoData")
    }
    func bottomLeftClick(){
        MyLog("bottomLeftClick")
    }
    func bottomRightClick(){
        MyLog("bottomRightClick")
        bottomView.clickAudioBtn(isShowKey: true)
    }
    func bottomSendClick(text: String) {
        MyLog("发送内容:\(text)")
        if !kkStringIsEmpty(text) {
            let item00 = ChatInfoItemRequest(chatType: 0, content: text, createTime:Int64(Date().timeIntervalSince1970), recordCreateTime: recordingItem?.createTime)
            try! ChatInfoItemStore.shared.addChatInfoItem(item00)
        }
        getData()
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return itemList.count
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemList[indexPath.row]
        let cell = tableView.dequeueCell(ChatInfoItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: model)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.01
    }
}

class ChatInfoItemCell: SuperTableViewCell {
    private var itemModel:ChatInfoItem? = nil
    private lazy var bgView = UILabel().backgroundColor(.white)
    private lazy var contentBg = UILabel()
    private lazy var contentL = UILabel().text("").hnFont(size: 14.h, weight: .regular).color(.white).lines(0)

    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        bgView.addChildView([contentBg])
        contentBg.addChildView([contentL])
        contentView.backgroundColor(.clear)
        
        let maxBubbleWidth = kkScreenWidth - 48.w

        bgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        contentBg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-8.h)
            // 关键：最大宽度限制
            make.width.lessThanOrEqualTo(maxBubbleWidth)
            // 左右对齐其中一个（根据消息方向控制）
            leadingConstraint = make.leading.equalToSuperview().offset(24.w).constraint
            trailingConstraint = make.trailing.equalToSuperview().offset(-24.w).constraint
        }
        
        contentL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.w)
            make.right.equalToSuperview().offset(-15.w)
            make.bottom.equalToSuperview().offset(-10.h)
            make.top.equalToSuperview().offset(10.h)
        }
        
        contentL.preferredMaxLayoutWidth = maxBubbleWidth
        contentL.setContentHuggingPriority(.required, for: .horizontal)
        contentL.setContentCompressionResistancePriority(.required, for: .horizontal)

    }
    
    func configure(with item: ChatInfoItem) {
        itemModel = item
//        contentL.text(itemModel?.content)
        contentL.attributedText = makeAttributedText((itemModel?.content)!)
        if itemModel?.chatType == 1 {
            contentBg.cornerRadius(14.h, corners: [.topLeft,.bottomLeft,.bottomRight]).backgroundColor(kkColorFromHex(kkMainColor)).rightAligned()
            contentL.color(.white)
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true

        }else{
            contentBg.cornerRadius(14.h, corners: [.topRight,.bottomLeft,.bottomRight]).backgroundColor(kkColorFromHex(kkHomeBgColor)).leftAligned()
            contentL.color(kkColorFromHex(kkMainTextColor))
            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = false

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

    
    func textHeight(
        _ text: String,
        font: UIFont,
        maxWidth: CGFloat,
        lineSpacing: CGFloat = 0
    ) -> CGFloat {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let rect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        return ceil(rect.height)
    }

}
