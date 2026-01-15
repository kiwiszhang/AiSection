//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFAudio
import Speech
import AVFoundation

@objc protocol DetailBottomViewDelegate: AnyObject {
    func refreshDetailBottomData(updatedText:String)
    func refreshDetailBottomNoData()
    func bottomLeftClick()
    func bottomRightClick()
    @objc optional func bottomSendClick(text: String)
    @objc optional func bottomClick()

}


class DetailBottomView: SuperView{
    weak var delegate: DetailBottomViewDelegate?
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var startPoint: CGPoint = .zero
    private var isCanceling = false
    private let cancelThreshold: CGFloat = 70  // 上滑 70pt 取消
    private var lastLevel: CGFloat = 0
    private var levelRecorder: AVAudioRecorder?
    private var meterTimer: CADisplayLink?

    // MARK: -  =====================lazyload=========================
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(12.h).border(width: 1, color: kkColorFromHex("DEE3EB"))

    private lazy var leftImage = UIImageView().image(Asset.chatIcon.image).enable(true).onTap { [self] in
        delegate?.bottomLeftClick()
    }
    private lazy var rightImage = UIImageView().image(Asset.chatAudio.image).enable(true).onTap { [self] in
        delegate?.bottomRightClick()
    }

    lazy var prompTextField = UITextField().holder(L10n.chatWithThisNote).delegate(self).backgroundColor(.white)
    
    private lazy var pressLable = UILabel().text(L10n.pressAndHoldToSpeak).hnFont(size: 16.h, weight: .regular).backgroundColor(.white).color(kkColorFromHex(kkMainColor)).centerAligned().hidden(true)

    private lazy var tipsLable = UILabel().text(L10n.releaseToSendSlideUpToCancel).hnFont(size: 12.h, weight: .regular).color(kkColorFromHex("A4A9B1")).centerAligned().hidden(true)
    
//    private lazy var recognitionView = WaveBarView().backgroundColor(kkColorFromHex(kkMainColor)).cornerRadius(12.h).hidden(true)
    private lazy var recognitionView = WaveBarView().backgroundColor(.systemRed).cornerRadius(12.h).hidden(true)

    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let g = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        g.minimumPressDuration = 0.3
        g.allowableMovement = 999  // 允许大幅移动
        return g
    }()

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor(.white)
        self.addChildView([bgView,recognitionView,tipsLable])
        bgView.addChildView([leftImage,rightImage,prompTextField,pressLable])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(347.w)
            make.height.equalTo(48.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(19.h)
        }
        
        recognitionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(bgView)
        }
        
        tipsLable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bgView.snp.top)
        }
        
        leftImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14.w)
        }

        rightImage.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6.w)
        }
        
        prompTextField.snp.makeConstraints { make in
            make.left.equalTo(leftImage.snp.right).offset(8.w)
            make.right.equalTo(rightImage.snp.left).offset(-8.w)
            make.centerY.equalToSuperview()
            make.height.equalTo(48.h)
        }
        prompTextField.returnKeyType = .send
        
        pressLable.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(prompTextField)
        }
        
        pressLable.isUserInteractionEnabled = true
        pressLable.addGestureRecognizer(longPressGesture)

    }
    override func getData() {
        
    }
    
    func bottonClick(){
        prompTextField.enable(false)
        bgView.onTap {
            self.delegate?.bottomClick?()
        }
    }
    
    // MARK: -  =======================actions========================
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: pressLable)

        switch gesture.state {

        case .began:
            startPoint = location
            isCanceling = false
            showRecordingUI(status: 0)
            startSpeechRecognition()
            startLevelMeter()
            startMeterTimer()

        case .changed:
            let offsetY = startPoint.y - location.y

            if offsetY > cancelThreshold {
                if !isCanceling {
                    isCanceling = true
                    showRecordingUI(status: 1)
                }
            } else {
                if isCanceling {
                    isCanceling = false
                    showRecordingUI(status: 0)
                }
            }

        case .ended, .cancelled, .failed:
            if isCanceling {
                cancelSpeechRecognition()
            } else {
                finishSpeechRecognition()
            }
            stopLevelMeter()
            resetRecordingUI()

        default:
            break
        }
    }

    private func startSpeechRecognition() {
        // 开始 AVAudioEngine + SFSpeechRecognizer
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.reset()
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        request.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0) // 使用硬件真实格式

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            self.request?.append(buffer)
            
            print("frameLength:", buffer.frameLength)
            let level = self.smoothLevel(self.audioLevel(from: buffer))
            DispatchQueue.main.async {
                self.recognitionView.update(level: level)
            }
        }

        audioEngine.prepare()
        try? audioEngine.start()

        let locale = Locale(identifier: UserDefaultsTools.recordLangugasSelected)
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.prompTextField.text = result.bestTranscription.formattedString
                MyLog("语音识别:\(result.bestTranscription.formattedString)")
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.request = nil
                self.recognitionTask = nil
            }
        }
        isCanceling = false
    }
    private func finishSpeechRecognition() {

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        audioEngine.reset()
        recognitionView.reset()

        recognitionTask?.finish()

        recognitionTask = nil
        request = nil
        MyLog("结束语音识别")
    }

    private func cancelSpeechRecognition() {

        // 1️⃣ 停止 AudioEngine
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        // 2️⃣ 移除 Tap（否则下次必 crash）
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        audioEngine.reset()

        // 3️⃣ 结束 request（不再接收音频）
        request?.endAudio()

        // 4️⃣ 取消识别任务（不会回调结果）
        recognitionTask?.cancel()

        // 5️⃣ 释放对象（非常重要）
        recognitionTask = nil
        request = nil
        recognitionView.reset()
        // 6️⃣ 可选：UI 提示
        MyLog("🎤 语音识别已取消")
    }

    private func startLevelMeter() {
        let url = URL(fileURLWithPath: "/dev/null")

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]

        levelRecorder = try? AVAudioRecorder(url: url, settings: settings)
        levelRecorder?.isMeteringEnabled = true
        levelRecorder?.prepareToRecord()
        levelRecorder?.record()
    }

    
    private func stopLevelMeter() {
        meterTimer?.invalidate()
        meterTimer = nil

        levelRecorder?.stop()
        levelRecorder = nil

        recognitionView.reset()
    }



    private func startMeterTimer() {
        meterTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        meterTimer?.add(to: .main, forMode: .common)
    }

    @objc private func updateMeter() {
        levelRecorder?.updateMeters()
        let power = levelRecorder?.averagePower(forChannel: 0) ?? -60

        let minDB: Float = -50
        let maxDB: Float = -10
        let level = max(0, min(1, (power - minDB) / (maxDB - minDB)))

        recognitionView.update(level: CGFloat(level))
    }


    private func resetRecordingUI() {
        // UI 恢复初始状态
        clickAudioBtn(isShowKey: false)
    }
    
    func clickAudioBtn(isShowKey:Bool){
        bgView.hidden(false)
        recognitionView.hidden(true)
        tipsLable.hidden(true)
        if isShowKey {
            pressLable.hidden(false)
            prompTextField.enable(false)
            rightImage.image(Asset.chatKeyborad.image)
        }else{
            pressLable.hidden(true)
            prompTextField.enable(true)
            rightImage.image(Asset.chatAudio.image)
        }
    }
    
    func showRecordingUI(status:Int){
        bgView.hidden(true)
        recognitionView.hidden(false)
        tipsLable.hidden(false)
        if status == 0 {
            recognitionView.backgroundColor(kkColorFromHex(kkMainColor))
//            recognitionView.backgroundColor(.systemRed)
            tipsLable.text(L10n.releaseToSendSlideUpToCancel).color(kkColorFromHex("A4A9B1"))
        }else if status == 1 {
            recognitionView.backgroundColor(kkColorFromHex("F93B61"))
//            recognitionView.backgroundColor(.systemYellow)
            tipsLable.text(L10n.releaseToCancel).color(kkColorFromHex("F93B61"))
        }
    }
    
    func smoothLevel(_ level: CGFloat) -> CGFloat {
        let smoothed = max(level, lastLevel * 0.8)
        lastLevel = smoothed
        return smoothed
    }
    
    func audioLevel(from buffer: AVAudioPCMBuffer) -> CGFloat {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }

        var rms: Float = 0
        let frameLength = Int(buffer.frameLength)

        for i in 0..<frameLength {
            rms += channelData[i] * channelData[i]
        }

        rms = sqrt(rms / Float(frameLength))

        let db = 20 * log10(rms)

        // 🔥 放大区间
        let minDB: Float = -45
        let maxDB: Float = -10

        let normalized = (db - minDB) / (maxDB - minDB)
        return CGFloat(max(0, min(1, normalized)))
    }


    
}

// MARK: -  =====================UITextFieldDelegate=========================
extension DetailBottomView:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取修改后的文本
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            delegate?.refreshDetailBottomNoData()
        } else {
            self.delegate?.refreshDetailBottomData(updatedText: updatedText)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            self.delegate?.refreshDetailBottomData(updatedText: text)
        } else {
            delegate?.refreshDetailBottomNoData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 点击发送按钮时触发
        delegate?.bottomSendClick?(text: textField.text ?? "")
        
        textField.text = "" // 可选，发送后清空输入框
        textField.resignFirstResponder() // 收起键盘
        return true
    }
}

final class WaveBarView: UIView {

    private var bars: [UIView] = []
    private let barCount = 18

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        for _ in 0..<barCount {
            let bar = UIView()
            bar.backgroundColor = .white
            bar.layer.cornerRadius = 2
            addSubview(bar)
            bars.append(bar)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let barWidth: CGFloat = 4
        let spacing: CGFloat = 6
        let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2

        for (i, bar) in bars.enumerated() {
            let x = startX + CGFloat(i) * (barWidth + spacing)
            bar.frame = CGRect(x: x, y: bounds.midY - 5.h, width: barWidth, height: 10.h)
        }
    }
    
    func reset() {
        for bar in bars {
            bar.frame.size.height = 10.h
            bar.frame.origin.y = bounds.midY - 5.h
        }
    }

    func update(level: CGFloat) {
        let maxHeight = bounds.height

        for (i, bar) in bars.enumerated() {
            let randomFactor = CGFloat.random(in: 0.6...1.2)
            let height = max(4, maxHeight * level * randomFactor)

            UIView.animate(withDuration: 0.1) {
                bar.frame.origin.y = self.bounds.midY - height / 2
                bar.frame.size.height = height
            }
        }
    }
}

