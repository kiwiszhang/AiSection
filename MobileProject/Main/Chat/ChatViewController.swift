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
    private lazy var itemList:[[SettingModel]] = []
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(SettingItem00Cell.self).registerCells(SettingItem01Cell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(70.h).showsH(false).showsV(false)
    }()
    private lazy var topView = ChatNavTopView()
    private lazy var tableHeaderView = ChatTableHeaderView().backgroundColor(.white)
    private lazy var bottomView = DetailBottomView()

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
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
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
        
        tableView.reloadData()
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
        // 在这里把消息添加到 tableView 或发送给服务器
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = itemList[indexPath.section][indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == itemList[indexPath.section].count - 1

        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(SettingItem00Cell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: model, isFirst: isFirst, isLast: isLast)
            return cell
        } else {
            let cell = tableView.dequeueCell(SettingItem01Cell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: model, isFirst: isFirst, isLast: isLast)
            return cell
        }
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
