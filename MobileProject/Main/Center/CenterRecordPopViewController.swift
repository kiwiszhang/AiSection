//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

class CenterRecordPopViewController: SuperViewController {

    var isRecording:Bool = false
    var dismissAction: (() -> Void)?
    private lazy var dowmImg = UIImageView().image(Asset.recordDowm.image).enable(true).onTap { [self] in
        dismissAction?()
    }
    private lazy var tipsLabe = UILabel().text(L10n.pleaseRecordForAtLeast10Seconds).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex("9BF9F9")).centerAligned()

    private lazy var animationTop = UIView()
    private lazy var pauseTop = UIImageView().image(Asset.recordAnimation.image).hidden(true)
    private lazy var videoTopView: VideoPlayerView? = nil
    
    private lazy var animationBottom = UIView()
    private lazy var pauseBottom = UIImageView().image(Asset.recordBottomA.image).hidden(true)
    private lazy var videoBottomView: VideoPlayerView? = nil

    private lazy var timeL = UILabel().text("00:00:00").hnFont(size: 30.h, weight: .medium).centerAligned().color(.white)
    
    private lazy var leftBtn = UIImageView().image(Asset.recordCancel.image).enable(true).onTap {
        MyLog("leftBtn")
        showAlertView(title: L10n.areSureYouWantToDiscardRecord,message: L10n.allProgressWillBeLost, confirmButtonTitle:L10n.delete, cancelButtonTitle:L10n.cancel,confirmButtonColor: "#FF3B30") { confirmed in
            if confirmed {
                // 用户点击确认
            } else {
                // 用户点击取消
            }
        }
    }
    private lazy var rightBtn = UIImageView().image(Asset.recordCheck.image).enable(true).onTap { [self] in
        MyLog("rightBtn")
        showAlertViewWithOutCancelButton(title: L10n.shortRecordingDetected,message: L10n.yourRecordingIsTooBriefForTranscription, confirmButtonTitle:L10n.gotIt) {confirmed in
            
            let vc = CenterProcessingVC()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
            
        }
    }
    private lazy var centerBtn = UIImageView().image(Asset.recordPlay.image).enable(true).onTap { [self] in
        MyLog("centerBtn")
        changeStatus()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeStatus(){
        if isRecording {
            pauseTop.hidden(true)
            pauseBottom.hidden(true)
            centerBtn.image(Asset.recordPlay.image)
        }else{
            pauseTop.hidden(false)
            pauseBottom.hidden(false)
            centerBtn.image(Asset.recordPuase.image)
        }
        isRecording = !isRecording
        
    }
    
    
    override func getData() {

        
    }
    
    override func setUpUI() {
        view.backgroundColor(kkColorFromHex("000516"))
        view.addChildView([dowmImg,tipsLabe,animationTop,animationBottom])

        dowmImg.snp.makeConstraints { make in
            make.width.height.equalTo(22.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12.h)
        }
        tipsLabe.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(17.h)
            make.top.equalTo(dowmImg.snp.bottom).offset(40.h)
        }

        animationTop.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tipsLabe.snp.bottom).offset(3.h)
            make.height.equalTo(375.h)
        }
        
        animationBottom.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(animationTop.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        
        let mp4Video = Bundle.main.url(forResource: Files.recordTopMp4.name, withExtension: "mp4")
        guard let mp4VideoUrl = mp4Video else { return }
        videoTopView = VideoPlayerView(fileURL: mp4VideoUrl).enable(true)
        animationTop.addSubview(videoTopView!)
        videoTopView?.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        videoTopView?.play()
        
        videoTopView?.addSubview(pauseTop)
        pauseTop.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let mp4VideoBottom = Bundle.main.url(forResource: Files.recordBottomMp4.name, withExtension: "mp4")
        guard let mp4VideoUrlBottom = mp4VideoBottom else { return }
        videoBottomView = VideoPlayerView(fileURL: mp4VideoUrlBottom).enable(true)
        animationBottom.addSubview(videoBottomView!)
        videoBottomView?.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        videoBottomView?.play()

        videoBottomView?.addChildView([pauseBottom,timeL,leftBtn,centerBtn,rightBtn])
        
        pauseBottom.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timeL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(36.h)
            make.top.equalToSuperview().offset(15.h)
        }
        
        centerBtn.snp.makeConstraints { make in
            make.width.height.equalTo(60.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeL.snp.bottom).offset(80.h)
        }
        
        leftBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50.h)
            make.centerY.equalTo(centerBtn)
            make.right.equalTo(centerBtn.snp.left).offset(-54.w)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50.h)
            make.centerY.equalTo(centerBtn)
            make.left.equalTo(centerBtn.snp.right).offset(54.w)
        }
        
    }
}


// MARK: -  =======================PopTopViewDelegate========================
extension CenterRecordPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}


