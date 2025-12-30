//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol DetailTableHeaderViewDelegate: AnyObject {
    func segmentTableHeaderViewClickIndex(index:Int)
    func allNoteClick()
    func tableHeaderPlayClick()
}


class DetailTableHeaderView: SuperView{
    weak var delegate: DetailTableHeaderViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var topView = UIView().backgroundColor(kkColorFromHexWithAlpha("317DFF", 0.16)).cornerRadius(25.h, corners: [.bottomLeft,.bottomRight])

    private lazy var titleL = UILabel().text("Welcome to the App! Discover all features").hnFont(size: 20.h, weight: .medium).color(kkColorFromHex(kkMainTextColor)).lines(2)
    private lazy var allNote = UILabel().text(L10n.allNotes).hnFont(size: 10.h, weight: .medium).backgroundColor(.white).cornerRadius(6.h).centerAligned().onTap { [self] in
        delegate?.allNoteClick()
    }
    private lazy var dateV = DetailItemView()
    private lazy var timeV = DetailItemView()
//    private lazy var recordV = DetailRecordView().backgroundColor(.white).cornerRadius(22.h)
    private lazy var recordV = AudioPlayerView().backgroundColor(.white).cornerRadius(22.h)
    lazy var segmentV = DetailSegmentView()
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        
        self.addChildView([topView,segmentV])
        
        topView.addChildView([titleL,allNote,dateV,timeV,recordV])
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(162.h)
        }
        
        segmentV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(4.h)
            make.height.equalTo(56.h)
        }
        segmentV.delegate = self
        
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(48.h)
        }
        
        allNote.snp.makeConstraints { make in
            make.width.equalTo(76.w)
            make.height.equalTo(26.h)
            make.top.equalTo(titleL.snp.bottom).offset(8.h)
            make.left.equalToSuperview().offset(20.w)
        }
        
        dateV.snp.makeConstraints { make in
            make.left.equalTo(allNote.snp.right).offset(14.w)
            make.width.equalTo(74.w)
            make.height.equalTo(14.h)
            make.centerY.equalTo(allNote)
        }
        
        timeV.snp.makeConstraints { make in
            make.left.equalTo(dateV.snp.right).offset(14.w)
            make.width.equalTo(74.w)
            make.height.equalTo(14.h)
            make.centerY.equalTo(allNote)
        }
        
        recordV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.w)
            make.right.equalToSuperview().offset(-15.w)
            make.height.equalTo(44.h)
            make.top.equalTo(allNote.snp.bottom).offset(14.h)
        }
//        recordV.delegate = self
        
        segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)


        let directory = RecorderManager.shared.recordingsDirectory()
        let urlFile = URL(string:"\(directory.absoluteString)" + "567.m4a")!
        guard let fileURL = URL(string: urlFile.absoluteString) else {
            MyLog("无可用文件或路径错误")
            return
        }
        MyLog(urlFile)
        MyLog(fileURL)
        recordV.loadAudio(url: fileURL)
    }
    override func getData() {
        dateV.updateData(icon: Asset.canlande.image, title: "Apr 10,2025")
        timeV.updateData(icon: Asset.timeShow.image, title: "11:30 am")
    }
    
    // MARK: -  =======================actions========================
    func stopAudios(){
        AudioPlaybackManager.shared.stop(recordV)
    }
    func updataNoteTitle(title:String){
        allNote.text(title)
    }
    func updateData(timeStamp:Int64){
        let result = formatTimestamp(timeStamp)
        dateV.updateData(icon: Asset.canlande.image, title: result.date)
        timeV.updateData(icon: Asset.timeShow.image, title: result.time)
    }
    func formatTimestamp(_ timestamp: Int64) -> (date: String, time: String) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let locale = Locale(identifier: "en_US_POSIX")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "MMM dd, yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "h:mm a"

        let dateText = dateFormatter.string(from: date)
        let timeText = timeFormatter.string(from: date)
            .replacingOccurrences(of: "AM", with: "am")
            .replacingOccurrences(of: "PM", with: "pm")

        return (dateText, timeText)
    }

    
}

class DetailItemView: SuperView{
    // MARK: -  =====================lazyload=========================
    private lazy var iconV = UIImageView().image(Asset.canlande.image)
    private lazy var titleL = UILabel().text("Apr 10,2025").hnFont(size: 10.h, weight: .regular).backgroundColor(.clear).color(kkColorFromHex(kkMainTextColor))
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        
        self.addChildView([iconV,titleL])
        
        iconV.snp.makeConstraints { make in
            make.width.height.equalTo(14.h)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        titleL.snp.makeConstraints { make in
            make.top.equalTo(iconV)
            make.left.equalTo(iconV.snp.right).offset(1)
            make.height.equalTo(iconV)
        }
        
    }
    override func getData() {
    }
    func updateData(icon:UIImage,title:String){
        iconV.image(icon)
        titleL.text(title)
    }
    // MARK: -  =======================actions========================
}


@objc protocol DetailRecordViewDelegate: AnyObject {
    func playClick()
}

class DetailRecordView: SuperView{
    weak var delegate: DetailRecordViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var iconV = UIImageView().image(Asset.playIcon.image).onTap { [self] in
        delegate?.playClick()
    }
    private lazy var titleL = UILabel().text("3:32").hnFont(size: 10.h, weight: .medium).backgroundColor(.systemRed).color(kkColorFromHex(kkMainColor)).centerAligned()
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        
        self.addChildView([iconV,titleL])
        
        iconV.snp.makeConstraints { make in
            make.width.height.equalTo(38.h)
            make.left.equalToSuperview().offset(3.w)
            make.centerY.equalToSuperview()
        }
        
        let widthL = "03:32".width(forFont: UIFont.interOner(size: 10.h, weight: .medium))
        
        titleL.snp.makeConstraints { make in
            make.centerY.equalTo(iconV)
            make.right.equalToSuperview().offset(-14.w)
            make.height.equalTo(12.h)
            make.width.equalTo(widthL + 10.w)
        }
        
    }
    override func getData() {
    }

    func updateData(){
        iconV.snp.remakeConstraints { make in
            make.width.height.equalTo(28.h)
            make.left.equalToSuperview().offset(3.w)
            make.centerY.equalToSuperview()
        }
    }
    // MARK: -  =======================actions========================
}

// MARK: -  =====================DetailSegmentViewDelegate=========================
extension DetailTableHeaderView:DetailSegmentViewDelegate {
    func segmentClickIndex(index:Int) {
        delegate?.segmentTableHeaderViewClickIndex(index: index)
    }
}

// MARK: -  =====================DetailRecordViewDelegate=========================
extension DetailTableHeaderView:DetailRecordViewDelegate {
    func playClick() {
        delegate?.tableHeaderPlayClick()
    }
}
