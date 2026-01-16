//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

struct ProcessItem {
    let title: String
    let subTitle: String
    let leftImage:UIImage
    let rightImage:UIImage
}

@objc protocol CenterProcessingVCDelegate: AnyObject {
    func backDismissProcessing()
}

class CenterProcessingVC: SuperViewController {
    weak var delegate: CenterProcessingVCDelegate?

    var itemList:[ProcessItem] = []
    var selecedRow = 0
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.white).registerCells(ProcessCell.self).scrollEnable(false).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(70.h).showsH(false)
    }()
    
    private lazy var bgView = UIView().backgroundColor(kkColorFromHex(kkMainColor))
    private lazy var backImageV = UIImageView().image(Asset.processingBack.image).enable(false).onTap {
        self.delegate?.backDismissProcessing()
        self.dismiss(animated: true)
    }
    
    private lazy var topBgView = UIView().backgroundColor(kkColorFromHex(kkMainColor)).cornerRadius(25.h, corners: [.bottomLeft,.bottomRight])
    private lazy var remainView = RemaindView().backgroundColor(kkColorFromHex("176EF6")).cornerRadius(14.h)
    private lazy var progressView = ProcessView().cornerRadius(14.h).backgroundColor(.systemCyan)

    
    private lazy var bottomBtn = UILabel().text(L10n.notifyMeWhenDone).hnFont(size: 18.h, weight: .medium).color(.white).backgroundColor(kkColorFromHex(kkMainColor)).centerAligned().cornerRadius(14.h).onTap {
        MyLog("bottomBtn")
        self.delegate?.backDismissProcessing()
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kkNotification_add(observer: self, selector: #selector(updateProcessingUI(_:)), name: NotificationCenterKeys.kHandleRecordingState.rawValue)
    }
    
    @objc func updateProcessingUI(_ notification: Notification){
        DispatchQueue.main.async { [self] in
            guard let state = notification.object as? HandleRecordingState else { return }
            bottomBtn.enable(true).alpha(1.0)
            backImageV.enable(false)
            MyLog(state.handleContent)
            if state.handleStatus == 1 {
                progressView.updateData(title: "", present: 0.25)
                bottomBtn.enable(false).alpha(0.4)
                remainView.updateData(title: L10n.processingInProgressPleaseDoNotLeave)
                
                let model00 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.enhanceAudioForBetterAccuracy, leftImage: Asset.processingAudio00.image,rightImage: Asset.processingLoading.image)
                let model01 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.speechToTextWithSmartPunctuation, leftImage: Asset.processingAudio01.image,rightImage: Asset.processingLoadingLight.image)
                let model02 = ProcessItem(title: L10n.highlightingKeyPoints, subTitle: L10n.decisionsActionsAndTakeaways, leftImage: Asset.processingPoints.image,rightImage: Asset.processingLoadingLight.image)
                let model03 = ProcessItem(title: L10n.wrappingUp, subTitle: L10n.deliverAShareReadySummary, leftImage: Asset.processingWrapping.image,rightImage: Asset.processingLoadingLight.image)
                itemList = [model00,model01,model02,model03]
            }
            if state.handleStatus == 2 {
                progressView.updateData(title: "", present: 0.5)
                backImageV.enable(true)
                remainView.updateData(title: L10n.itIsSafeToLeave)
                let model00 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.enhanceAudioForBetterAccuracy, leftImage: Asset.processingAudio00.image,rightImage: Asset.addNoteCheck.image)
                let model01 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.speechToTextWithSmartPunctuation, leftImage: Asset.processingAudio01.image,rightImage: Asset.processingLoading.image)
                let model02 = ProcessItem(title: L10n.highlightingKeyPoints, subTitle: L10n.decisionsActionsAndTakeaways, leftImage: Asset.processingPoints.image,rightImage: Asset.processingLoadingLight.image)
                let model03 = ProcessItem(title: L10n.wrappingUp, subTitle: L10n.deliverAShareReadySummary, leftImage: Asset.processingWrapping.image,rightImage: Asset.processingLoadingLight.image)
                itemList = [model00,model01,model02,model03]
            }
            
            if state.handleStatus == 3 {
                progressView.updateData(title: "", present: 0.75)
                backImageV.enable(true)
                let model00 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.enhanceAudioForBetterAccuracy, leftImage: Asset.processingAudio00.image,rightImage: Asset.addNoteCheck.image)
                let model01 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.speechToTextWithSmartPunctuation, leftImage: Asset.processingAudio01.image,rightImage: Asset.addNoteCheck.image)
                let model02 = ProcessItem(title: L10n.highlightingKeyPoints, subTitle: L10n.decisionsActionsAndTakeaways, leftImage: Asset.processingPoints.image,rightImage: Asset.processingLoading.image)
                let model03 = ProcessItem(title: L10n.wrappingUp, subTitle: L10n.deliverAShareReadySummary, leftImage: Asset.processingWrapping.image,rightImage: Asset.processingLoadingLight.image)
                itemList = [model00,model01,model02,model03]
            }
            
            if state.handleStatus == 4 {
                progressView.updateData(title: "", present: 1.0)
                backImageV.enable(true)
                let model00 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.enhanceAudioForBetterAccuracy, leftImage: Asset.processingAudio00.image,rightImage: Asset.addNoteCheck.image)
                let model01 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.speechToTextWithSmartPunctuation, leftImage: Asset.processingAudio01.image,rightImage: Asset.addNoteCheck.image)
                let model02 = ProcessItem(title: L10n.highlightingKeyPoints, subTitle: L10n.decisionsActionsAndTakeaways, leftImage: Asset.processingPoints.image,rightImage: Asset.addNoteCheck.image)
                let model03 = ProcessItem(title: L10n.wrappingUp, subTitle: L10n.deliverAShareReadySummary, leftImage: Asset.processingWrapping.image,rightImage: Asset.addNoteCheck.image)
                itemList = [model00,model01,model02,model03]
            }
            
            tableView.reloadData()
        }
    }
    
    override func setUpUI() {
        view.backgroundColor(kkColorFromHex("F2F4F8"))
        view.addChildView([bgView,topBgView,tableView,bottomBtn])

        bgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kkNAVIGATION_BAR_HEIGHT)
        }
        bgView.addSubview(backImageV)
        backImageV.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.left.equalToSuperview().offset(14.h)
            make.bottom.equalToSuperview().offset(-13.h)
        }
        
        topBgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(bgView.snp.bottom)
            make.height.equalTo(180.h)
        }
        topBgView.addSubview(remainView)
        topBgView.addSubview(progressView)
        remainView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(50.h)
            make.top.equalToSuperview().offset(12.h)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(80.h)
            make.top.equalTo(remainView.snp.bottom).offset(14.h)
        }

        bottomBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalTo(50.h)
            make.bottom.equalToSuperview().offset(-(kkSAFE_AREA_BOTTOM + 10.h))
        }
        
        tableView.cornerRadius(14.h)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.top.equalTo(topBgView.snp.bottom).offset(24.h)
            make.bottom.equalTo(bottomBtn.snp.top).offset(-75.h)
        }
    }

    override func getData() {
        
        progressView.addGradientBackground(colors: [kkColorFromHex("D4E4FF"),kkColorFromHex("D9EDFF"),kkColorFromHex("BAD6FF")], direction: .bottomLeftToTopRight)
        progressView.updateData(title: "", present: 0.0)
        
        let model00 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.enhanceAudioForBetterAccuracy, leftImage: Asset.processingAudio00.image,rightImage: Asset.processingLoading.image)
        let model01 = ProcessItem(title: L10n.processingAudio, subTitle: L10n.speechToTextWithSmartPunctuation, leftImage: Asset.processingAudio01.image,rightImage: Asset.processingLoadingLight.image)
        let model02 = ProcessItem(title: L10n.highlightingKeyPoints, subTitle: L10n.decisionsActionsAndTakeaways, leftImage: Asset.processingPoints.image,rightImage: Asset.processingLoadingLight.image)
        let model03 = ProcessItem(title: L10n.wrappingUp, subTitle: L10n.deliverAShareReadySummary, leftImage: Asset.processingWrapping.image,rightImage: Asset.processingLoadingLight.image)
        itemList = [model00,model01,model02,model03]
        
        tableView.reloadData()
    }
    
}


//MARK: ----------TableViewDelegateDataSource-----------
extension CenterProcessingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemList[indexPath.row]
        let cell = tableView.dequeueCell(ProcessCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: item)
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

class ProcessCell: SuperTableViewCell {
    private lazy var titleLab = UILabel().hnFont(size: 16.h, weight: .medium).color(kkColorFromHex(kkMainTitleColor))
    private lazy var subTitleLab = UILabel().hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    private lazy var leftImg = UIImageView().image(Asset.processingLoading.image)
    private lazy var rightImg = UIImageView().image(Asset.processingLoadingLight.image)
    private lazy var line = UIView().backgroundColor(kkColorFromHex("E8EBF0"))

    override func setUpUI() {
        contentView.addChildView([line,titleLab,subTitleLab, rightImg,leftImg])
        
        rightImg.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20.h)
            make.right.equalToSuperview().offset(-16.w)
        }
        
        leftImg.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38.h)
            make.left.equalToSuperview().offset(16.w)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(leftImg.snp.right).offset(16.h)
            make.top.equalTo(leftImg.snp.top)
            make.right.equalTo(rightImg.snp.left).offset(-10.w)
            make.height.equalTo(19.h)
        }
        subTitleLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.height.equalTo(15.h)
            make.top.equalTo(titleLab.snp.bottom).offset(2.h)
        }
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0.w)
            make.right.equalToSuperview().offset(0.w)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with item: ProcessItem) {
        titleLab.text = item.title
        subTitleLab.text = item.subTitle
        leftImg.image(item.leftImage)
        rightImg.image(item.rightImage)
    }
}

class RemaindView: SuperView {
//    weak var delegate: RefreshDataDelegate?

    // MARK: -  =====================lazyload=========================
    private var leftImg = UIImageView().image(Asset.processingRemained.image)
    private var remaindL = UILabel().text(L10n.processingInProgressPleaseDoNotLeave).hnFont(size: 12.h, weight: .regular).lines(3).color(.white)
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([leftImg,remaindL])
        leftImg.snp.makeConstraints { make in
            make.width.height.equalTo(20.w)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10.w)
        }
        
        remaindL.snp.makeConstraints { make in
            make.left.equalTo(leftImg.snp.right).offset(7.w)
            make.right.equalToSuperview().offset(-10.w)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: -  =======================actions========================
    func updateData(title:String){
        remaindL.text(title)
    }
    
    // MARK: -  =====================delegate=========================
    
}

class ProcessView: SuperView {
//    weak var delegate: RefreshDataDelegate?

    // MARK: -  =====================lazyload=========================
    private var processL = UILabel().text(L10n.progress).hnFont(size: 14.h, weight: .medium)
    private var persentL = UILabel().text("10%").hnFont(size: 14.h, weight: .medium).rightAligned()
    private lazy var progressV = LinearProgressView(config: LinearProgressViewConfig(progressColor: kkColorFromHex(kkMainColor), trackColor: .white, animateDuration: 0.3))
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([processL,persentL,progressV])
        processL.snp.makeConstraints { make in
            make.height.equalTo(17.h)
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview().offset(20.h)
            make.width.equalTo(180.w)
        }
        
        persentL.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(20.h)
            make.height.equalTo(17.h)
            make.left.equalTo(processL.snp.right)
        }
        
        progressV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalTo(12.h)
            make.top.equalTo(processL.snp.bottom).offset(10.h)
        }
    }
    
    // MARK: -  =======================actions========================
    func updateData(title:String,present:CGFloat){
        persentL.text("\(present * 100) %")
        progressV.setProgress(present)
    }
    
    // MARK: -  =====================delegate=========================
    
}
