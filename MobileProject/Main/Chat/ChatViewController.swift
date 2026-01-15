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

    private lazy var scrollToBottomButton = UIImageView().image(Asset.chatDown.image).enable(true).hidden(true).shadow(kkColorFromHexWithAlpha("000000", 0.16), 12.h, 4, 0, 4.h).onTap { [self] in
        let lastRow = itemList.count - 1
        if lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    private let showThreshold: CGFloat = 88.h
    private var isControlVisible = false
    private var isShowKey = false
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
                MyLog("语音识别授权成功")
                self.checkMicrophonePermission(from: self)
            default:
                MyLog("语音识别未授权")
                self.showPermissionAlert(from: self, type: L10n.sfSpeechRecognizer)
            }
        }

    }
    
    func checkMicrophonePermission(from vc: UIViewController) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async { [self] in
                if granted {
                    MyLog("麦克风授权成功")
                    isShowKey = !isShowKey
                    bottomView.clickAudioBtn(isShowKey: isShowKey)
                } else {
                    MyLog("麦克风未授权")
                    self.showPermissionAlert(from: vc, type: L10n.checkMicrophonePermission)
                }
            }
        }
    }
    
    // 弹框提示用户去设置
    private func showPermissionAlert(from vc: UIViewController, type: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: L10n.somePermissionNoOpen(type),
                message: L10n.openPermission(type),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
            alert.addAction(UIAlertAction(title: L10n.gotoSettings, style: .default, handler: { _ in
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }))
            vc.present(alert, animated: true)
        }
    }
    
    
    override func setUpUI() {
        
        view.addChildView([tableView,topView,bottomView,scrollToBottomButton])
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

        scrollToBottomButton.snp.makeConstraints { make in
            make.width.height.equalTo(34.h)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).offset(-8.h)
        }

    }
    
    override func getData() {
        topView.delegate = self
        bottomView.delegate = self
        itemList = try! ChatInfoItemStore.shared.fetchAllChatInfoItemWithRecordCreateTime(createTime: recordingItem!.createTime)
        tableView.reloadData()
        tableHeaderView.updateData(item: recordingItem!)
        
        // 判断是否显示按钮
        DispatchQueue.main.async {
            self.updateScrollToBottomButtonVisibility()
        }
    }
    
    // MARK: - 判断按钮显示
    func updateScrollToBottomButtonVisibility() {
        let contentHeight = tableView.contentSize.height
        let tableHeight = tableView.frame.height

        scrollToBottomButton.isHidden = contentHeight <= tableHeight
    }

}

// MARK: -  =======================ChatNavTopViewDelegate========================
extension ChatViewController:ChatNavTopViewDelegate {
    func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
    func moreClick(){
        MyLog("ChatNavTopViewDelegate")
        self.navigationController?.pushViewController(ChatHistoryViewController(recordingItem: recordingItem!), animated: true)
    }
    func shareClick(){
        MyLog("ChatNavTopViewDelegate")
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
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                MyLog("语音识别授权成功")
                self.checkMicrophonePermission(from: self)
            default:
                MyLog("语音识别未授权")
                self.showPermissionAlert(from: self, type: "语音识别")
            }
        }
    }
    func bottomSendClick(text: String) {
        MyLog("发送内容:\(text)")
        isShowKey = false
        if !kkStringIsEmpty(text) {
            let item00 = ChatInfoItemRequest(chatType: 0, content: text, createTime:Int64(Date().timeIntervalSince1970), recordCreateTime: recordingItem?.createTime, responseId: " ")
            try! ChatInfoItemStore.shared.addChatInfoItem(item00)
            Task {
                do {
                    let chatlist = try! ChatInfoItemStore.shared.fetchChatInfoItemWithRecordCreateTimeAndChatType(createTime: recordingItem!.createTime, chatType: 1)
                    if !chatlist.isEmpty {
                        let chatItem = chatlist.last
                        let decoded = try await requestDoubaoResponseMutilChat(text: text, responseId: (chatItem?.responseId)!)
                        let reply = extractAssistantText(from: decoded)
                        if !kkStringIsEmpty(reply) {
                            let item00 = ChatInfoItemRequest(chatType: 1, content: reply, createTime:Int64(Date().timeIntervalSince1970), recordCreateTime: recordingItem?.createTime, responseId: decoded.id)
                            try! ChatInfoItemStore.shared.addChatInfoItem(item00)
                            getData()
                        }
                        MyLog("AI 回复：\(reply)")
                    }else{
    //                    let reply = try await requestDoubaoChat(text: text)
                        let decoded = try await requestDoubaoResponse(text: text)
                        let reply = extractAssistantText(from: decoded)
                        if !kkStringIsEmpty(reply) {
                            let item00 = ChatInfoItemRequest(chatType: 1, content: reply, createTime:Int64(Date().timeIntervalSince1970), recordCreateTime: recordingItem?.createTime, responseId: decoded.id)
                            try! ChatInfoItemStore.shared.addChatInfoItem(item00)
                            getData()
                        }
                        MyLog("AI 回复：\(reply)")
                    }
                } catch {
                    MyLog("请求失败：\(error)")
                }
            }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let threshold: CGFloat = 100

        let minOffsetY = -scrollView.adjustedContentInset.top
        if scrollView.contentOffset.y < minOffsetY {
            scrollView.contentOffset.y = minOffsetY
        }
        let offsetY = scrollView.contentOffset.y
        
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        scrollToBottomButton.isHidden = maxOffset - offsetY <= threshold

        
        if offsetY >= showThreshold, !isControlVisible {
            showControl()
            isControlVisible = true
        } else if offsetY < showThreshold, isControlVisible {
            hideControl()
            isControlVisible = false
        }
    }
    
    private func showControl() {
        topView.backgroundColor(.white)
    }

    private func hideControl() {
        topView.backgroundColor(.clear)
    }
}

class ChatInfoItemCell: SuperTableViewCell {
    private var itemModel:ChatInfoItem? = nil
    private lazy var bgView = UILabel().backgroundColor(.white)
    private lazy var contentBg = UILabel()
    private lazy var contentL = CopyableLabel().text("").hnFont(size: 14.h, weight: .regular).color(.white).lines(0)

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

    
    
    func configure(with item: ChatInfoItem) {
        itemModel = item
//        contentL.text(itemModel?.content)
        contentL.attributedText = makeAttributedText((itemModel?.content)!)
        if itemModel?.chatType == 0 {
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

final class CopyableLabel: UILabel {

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        action == #selector(copy(_:))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
}

