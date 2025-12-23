//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

class CenterAudioPopViewController: SuperViewController {

    var dismissAction: (() -> Void)?
    private lazy var barView = PopTopView()
    private lazy var audioView = TitleFieldView()
    private lazy var languageView = TitleFieldView()
    private lazy var floderView = TitleFieldView()
    private lazy var getBtn = UILabel().text(L10n.getSummary).hnFont(size: 18.h, weight: .medium).color(.white).backgroundColor(kkColorFromHex(kkMainColor)).centerAligned().cornerRadius(14.h).onTap {
        MyLog("getBtn")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUpUI() {
        view.addChildView([barView,audioView,languageView,floderView,getBtn])

        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }

        audioView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(barView.snp.bottom).offset(5.h)
            make.height.equalTo(82.h)
        }
        
        languageView.snp.makeConstraints { make in
            make.left.height.right.equalTo(audioView)
            make.top.equalTo(audioView.snp.bottom).offset(20.h)
        }
        
        floderView.snp.makeConstraints { make in
            make.left.height.right.equalTo(audioView)
            make.top.equalTo(languageView.snp.bottom).offset(20.h)
        }
        
        getBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(floderView.snp.bottom).offset(40.h)
            make.height.equalTo(50.h)
        }
        
        
    }

    override func getData() {
        barView.delegate = self
        barView.updateData(title: L10n.uploadVideo)
        
        audioView.delegate = self
        audioView.updateData(title: L10n.audioFiles, prompTitle: L10n.fileName)
        
        languageView.delegate = self
        languageView.updateData(title: L10n.languageOfSummaryTranscript, prompTitle: L10n.automatic,isShowDowm: true)
        
        floderView.delegate = self
        floderView.updateData(title: L10n.folder, prompTitle: L10n.none,isShowDowm: true)
        
    }
    

}


// MARK: -  =======================PopTopViewDelegate========================
extension CenterAudioPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

// MARK: -  =======================TitleFieldViewDelegate========================
extension CenterAudioPopViewController:TitleFieldViewDelegate {
    func refreshData(updatedText:String,selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("audioView")
        }else if selfView == languageView {
            MyLog("languageView")
        }else if selfView == floderView {
            MyLog("floderView")
        }
    }
    func refreshNoData(selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("refreshNoData---audioView")
        }else if selfView == languageView {
            MyLog("refreshNoData---languageView")
        }else if selfView == floderView {
            MyLog("refreshNoData---floderView")
        }
    }
    
    func clickDowm(selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("clickDowm---audioView")
        }else if selfView == languageView {
            MyLog("clickDowm---languageView")
            
            let content = CenterLanguagePopVC()
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            self.present(popup, animated: false)
            
        }else if selfView == floderView {
            MyLog("clickDowm---floderView")
        }
    }
}
