//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation

class CenterRecordPopViewController: SuperViewController {

    private var timer: Timer?
    var dismissAction: (() -> Void)?
    private lazy var dowmImg = UIImageView().image(Asset.recordDowm.image).enable(true).onTap { [self] in
        dismissAction?()
    }
    private lazy var tipsLabe = UILabel().text(L10n.pleaseRecordForAtLeast10Seconds).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex("9BF9F9")).centerAligned().hidden(true)

    private lazy var animationTop = UIView()
    private lazy var pauseTop = UIImageView().image(Asset.recordAnimation.image).hidden(true)
    private lazy var videoTopView: VideoPlayerView? = nil
    
    private lazy var animationBottom = UIView()
    private lazy var pauseBottom = UIImageView().image(Asset.recordBottomA.image).hidden(true)
    private lazy var videoBottomView: VideoPlayerView? = nil

    private lazy var timeL = UILabel().text("00:00:00").hnFont(size: 30.h, weight: .medium).centerAligned().color(.white)
    
    private lazy var leftBtn = UIImageView().image(Asset.recordCancel.image).enable(true).onTap {
        MyLog("leftBtn")
        showAlertView(title: L10n.areSureYouWantToDiscardRecord,message: L10n.allProgressWillBeLost, confirmButtonTitle:L10n.delete, cancelButtonTitle:L10n.cancel,confirmButtonColor: "#FF3B30") { [self] confirmed in
            
            if RecorderManager.shared.microphonePermissionStatus() != .granted {
                pauseTop.hidden(false)
                pauseBottom.hidden(false)
                centerBtn.image(Asset.recordPuase.image)
                RecorderManager.shared.stop()
                return
            }
            
            if confirmed {
                RecorderManager.shared.stop()
                // 用户点击确认
                let files = RecorderManager.shared.fetchAllRecordings()

                // 删除单个
                RecorderManager.shared.deleteRecording(at: files.last!)

                // 删除多个
//                RecorderManager.shared.deleteRecordings(selectedFiles)

                pauseTop.hidden(false)
                pauseBottom.hidden(false)
                centerBtn.image(Asset.recordPuase.image)
                
            } else {
                // 用户点击取消
            }
        }
    }
    private lazy var rightBtn = UIImageView().image(Asset.recordCheck.image).enable(true).onTap { [self] in
        MyLog("rightBtn")
        
        let duration = RecorderManager.shared.recordingDuration()
        if duration < 10 {
            tipsLabe.hidden(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else {return}
                self.tipsLabe.hidden(true)
            }
        }else{
            showAlertViewWithOutCancelButton(title: L10n.shortRecordingDetected,message: L10n.yourRecordingIsTooBriefForTranscription, confirmButtonTitle:L10n.gotIt) { [self]confirmed in
                
                RecorderManager.shared.stop()

                pauseTop.hidden(false)
                pauseBottom.hidden(false)
                centerBtn.image(Asset.recordPuase.image)

                
                let recordURL = RecorderManager.shared.recordURL
                MyLog(recordURL)
                guard let lastFile = recordURL,let fileURL = URL(string: lastFile.absoluteString) else {
                    MyLog("上传失败：无可用文件或路径错误")
                    return
                }
                
                var tosKey = ""
                if !kkStringIsEmpty(fileURL.path) {
                    let result = fileURL.path.components(separatedBy: "/Documents/")
                    if result.count == 2 {
                        tosKey = result[1]
                    }
                }
                
                // 1. 初始化客户端
                let credential = TOSCredential.init(accessKey: AKeyID02 + AKeyID01, secretKey: SAKey)
                let tosEndpoint = TOSEndpoint(urlString: TOS_ENDPOINT, withRegion: TOS_REGION)
                let config = TOSClientConfiguration(endpoint: tosEndpoint, credential: credential)
                let client = TOSClient.init(configuration: config)

                // 2. 上传本地文件
                let put = TOSPutObjectFromFileInput()
                put.tosBucket = TOS_BUCKET
                put.tosKey = tosKey
                MyLog(fileURL.path)
                put.tosFilePath = fileURL.path
                let task = client.putObject(fromFile: put)

                task.continueWith { t in
                    if ((task.error == nil)) {
                        MyLog("Put object from file success.");
                        let output = task.result;
                        MyLog(output)
                    } else {
                        MyLog("Put object from file failed, error: \(String(describing: task.error))");
                    }
                    return nil
                }

                let vc = CenterProcessingVC()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
    }
    private lazy var centerBtn = UIImageView().image(Asset.recordPlay.image).enable(true).onTap { [self] in
        MyLog("centerBtn")
        changeRecordingStatus()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            updateRecordTime()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func changeRecordingStatus(){
            
        let manager = RecorderManager.shared
        
        if manager.microphonePermissionStatus() != .granted {
            showMicPermissionAlert()
            return
        }
        
        if manager.isRecording {
            // 显示“暂停”按钮
            pauseTop.hidden(false)
            pauseBottom.hidden(false)
            centerBtn.image(Asset.recordPuase.image)
            manager.pause()
        } else if manager.state == .paused {
            // 显示“开始录音”按钮
            pauseTop.hidden(true)
            pauseBottom.hidden(true)
            centerBtn.image(Asset.recordPlay.image)
            manager.resume()
        } else {
            pauseTop.hidden(true)
            pauseBottom.hidden(true)
            centerBtn.image(Asset.recordPlay.image)
            try? manager.startRecording()
        }
    }
    
    override func getData() {
        RecorderManager.shared.requestPermission { [self] granted in
            if granted {
                try? RecorderManager.shared.startRecording()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else {return}
                    showMicPermissionAlert()
                }
            }
        }
    }
    
    func showMicPermissionAlert() {
        showAlertView(title: L10n.noPermission,message: L10n.microSettings, confirmButtonTitle:L10n.gotoSettings, cancelButtonTitle:L10n.cancel,confirmButtonColor: "#FF3B30") { [self] confirmed in
            if !confirmed {
                pauseTop.hidden(false)
                pauseBottom.hidden(false)
                centerBtn.image(Asset.recordPuase.image)
                RecorderManager.shared.stop()
            } else {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
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
        
//        updateRecordTime()
        timeL.text("00:00")

    }
    
    func updateRecordTime(){
        let duration = RecorderManager.shared.recordingDuration()
        let text = String(format: "%02d:%02d",
                          Int(duration) / 60,
                          Int(duration) % 60)
        timeL.text(text)
    }
}


// MARK: -  =======================PopTopViewDelegate========================
extension CenterRecordPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}


