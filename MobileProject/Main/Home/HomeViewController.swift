//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

struct RecordItemModel {
    /// tab第一个和第三个用到的数据
    var noteName: String = ""
    var noteType: Int = 0
    var updateTime: Int64 = 0
    var isFavorite: Bool = false
    
    var isDemo: Bool = false
    var demoSubTitle: String = L10n.discoverAllFeatureswithThisNote
    var demoTry: String = L10n.tryNow
    
    /// 第二个tab用到的数据
    var floderName:String = ""
    var noteNumbers:Int = 0
    var isAddFloder: Bool = false

}

class HomeViewController: SuperViewController {
    private lazy var topview = TopView()
    private lazy var tabView = TabView()
    private lazy var itemList:[RecordingItem] = []
    private lazy var itemFolderList:[FolderItem] = []
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).registerCells(RecordSecendItemCell.self).registerCells(RecordItemDemoCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false).showsV(false)
    }()
    private lazy var emptyView = SectionEmptyView().hidden(true)
    private lazy var emptyAddView = SectionEmptyAddView().hidden(true)
    private lazy var tipsLable = TipsTopView().cornerRadius(12.h).backgroundColor(kkColorFromHex("00D5A4")).hidden(true)
    
    private lazy var searchText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
        
//        addNoteData()
//        addFolderData()
        
//        try! FolderItemStore.shared.deleteAllFolderItems()

    }
    
    func addNoteData(){
        let item00 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 1, handleType: 1, recordPath: "567.m4a", recordName: "test-Record-Name567", recordFolder: "Note00", recordFolderId: UUID().uuidString, isFavorite: false, createTime: Int64(Date().timeIntervalSince1970),transcriptionData: nil)
        let item01 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 0, handleType: 1, recordPath: "567.m4a", recordName: "test-Record-Name678", recordFolder: "Note01", recordFolderId: UUID().uuidString, isFavorite: true, createTime: Int64(Date().timeIntervalSince1970),transcriptionData: nil)
        let item02 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 1, handleType: 1, recordPath: "567.m4a", recordName: "test-Record-Name789", recordFolder: "Note00", recordFolderId: UUID().uuidString, isFavorite: false, createTime: Int64(Date().timeIntervalSince1970),transcriptionData: nil)
        let item03 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 0, handleType: 1, recordPath: "567.m4a", recordName: "test-Record-Name890", recordFolder: "Note01", recordFolderId: UUID().uuidString, isFavorite: true, createTime: Int64(Date().timeIntervalSince1970),transcriptionData: nil)

        do{
            try! RecordingItemStore.shared.addRecordingItem(item00)
            try! RecordingItemStore.shared.addRecordingItem(item01)
            try! RecordingItemStore.shared.addRecordingItem(item02)
            try! RecordingItemStore.shared.addRecordingItem(item03)
        }
    }
    
    func addFolderData(){
        let item00 = FolderItemRequest(folderName: "Note012", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item01 = FolderItemRequest(folderName: "Note123", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item02 = FolderItemRequest(folderName: "Note234", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item03 = FolderItemRequest(folderName: "Note345", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))

        do{
            try! FolderItemStore.shared.addFolderItem(item00)
            try! FolderItemStore.shared.addFolderItem(item01)
            try! FolderItemStore.shared.addFolderItem(item02)
            try! FolderItemStore.shared.addFolderItem(item03)
        }
    }
    
    
    override func setUpUI() {
        UserDefaultsTools.tabSelected = 0
        view.addChildView([topview,tabView,tableView,emptyView,emptyAddView,tipsLable])
        topview.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(142.h)
        }
        
        tabView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topview.snp.bottom).offset(18.h)
            make.height.equalTo(40.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom).offset(20.h)
            make.bottom.equalToSuperview().offset(-kkTAB_BAR_TOTAL_HEIGHT)
        }
        
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(150.h)
            make.height.equalTo(165.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20.h)
        }
        
        emptyAddView.snp.makeConstraints { make in
            make.width.equalTo(150.w)
            make.height.equalTo(254.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20.h)
        }
        
        topview.delegate = self
        tabView.delegate = self
        
        tipsLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(40.h)
            make.top.equalToSuperview().offset(53.h)
        }

    }
    override func getData() {
        tabClickItemIndex(0)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        kkNotification_add(observer: self, selector: #selector(updateTableView), name: NotificationCenterKeys.kUpdateTableViewData.rawValue)
        kkNotification_add(observer: self, selector: #selector(updateProcessingUI(_:)), name: NotificationCenterKeys.kHandleRecordingState.rawValue)
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
    
    @objc func updateProcessingUI(_ notification: Notification){
        DispatchQueue.main.async { [self] in
            guard let state = notification.object as? HandleRecordingState else { return }
            if state.handleStatus == 0 {
                tipsLable.hidden(false).backgroundColor(kkColorFromHex("F93B61"))
                tipsLable.updateData(image: Asset.tipsFailder.image, title: L10n.yourNoteProcessingFailed)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self = self else {return}
                    self.tipsLable.hidden(true)
                }
            }
            if state.handleStatus == 1 {
                
            }
            if state.handleStatus == 2 {
                
            }
            
            if state.handleStatus == 3 {
                tipsLable.hidden(false).backgroundColor(kkColorFromHex("00D5A4"))
                tipsLable.updateData(image: Asset.tipsCompletion.image, title: L10n.yourNotesIsReady)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self = self else {return}
                    self.tipsLable.hidden(true)
                }
            }
            
            if state.handleStatus == 4 {
                
            }
            tableView.reloadData()
        }
    }
    @objc func updateTableView(){
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}


// MARK: -  =======================TopViewDelegate========================
extension HomeViewController:TopViewDelegate {
    func refreshSearchData(updatedText: String) {
        MyLog(updatedText)
        searchText = updatedText
        if UserDefaultsTools.tabSelected == 0 {
            let listData = try! RecordingItemStore.shared.searchByKeyword(updatedText)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 2 {
            let listData = try! RecordingItemStore.shared.searchByKeyword(updatedText,in: true)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 1 {
            let listData = try! FolderItemStore.shared.searchByKeyword(updatedText)
            itemFolderList = listData
        }
        tableView.reloadData()
        listDataisEmpty()
    }
    func refreshSearchNoData(){
        MyLog("refreshSearchNoData")
        searchText = ""
        if UserDefaultsTools.tabSelected == 0 {
            try! RecordingItemStore.shared.removeDuplicateRecordingItemKeepLast()
            let listData = try! RecordingItemStore.shared.fetchAllRecordingItem()
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 2 {
            try! RecordingItemStore.shared.removeDuplicateRecordingItemKeepLast()
            let listData = try! RecordingItemStore.shared.fetchAllRecordingItem(isFavorite: true)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 1 {
            try! FolderItemStore.shared.removeDuplicateFolderItemKeepLast()
            let listData = try! FolderItemStore.shared.fetchAllFolderOutAllNotesItem(isContainerLast: true)
            itemFolderList = listData
        }
        tableView.reloadData()
        listDataisEmpty()
    }
    func clickVipImage() {
        MyLog("clickVipImage")
//        self.navigationController?.pushViewController(EditorViewController(), animated: true)
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            return itemList.count
        }
        if UserDefaultsTools.tabSelected == 1 {
            return itemFolderList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            let model = itemList[indexPath.row]
            if UtitilTools.isDemoData(model: model) {
                let cell = tableView.dequeueCell(RecordItemDemoCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell
            }
            let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: model)
            return cell
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            let model = itemFolderList[indexPath.row]
            let cell = tableView.dequeueCell(RecordSecendItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: model)
            return cell
        }
        
        let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            let item = itemList[indexPath.row]
            if UtitilTools.isDemoData(model: item) {
                MyLog("Demo")
            }else{
//                MBProgressHUD.showHUD()
                
//                let content = "然后第三个是对照片编辑类的竞品进行初步调研需求整理，然后这边跟军哥对了基本的功能的结构图。然后这周的工作计划是图片编辑类 APP 1.0版本的需求文档和原型输出。第二是拼图的视频编辑功能，2.0原型修改。第三是推动一下那个 Flash Boys 2.0版本的模板和活动的这两个模块。你讲完了。AFO 这边，上周的主要是Bootstrap 的 logo 测试规划，上下图优化，英文版，然后还有意大利、印尼的元素赚钱。然后扫描记账这边的上下图优化的规划，然后还有漏测测试第二第二版的提交。然后本周的计划是扫描记账的英语英语，简体中文，繁体中文。规划，还有数据撰写。Flash boots 的泰国、越南的商家图规划，还有数据撰写。还有扫扫描记账和 Flash boots 的自定义页面规划。我这边就这些。我上周是负责做冥想冥想模块，然后还有就是闹钟唤醒模块的一些界面设计以及一些交互的优化，然后还有就是首页新增的那个。整个的金刚区的一个功能入口。然后本周的话是，对接志祥这边把前面的引导以及订阅页的一个界面还原度以及动画效果，和他校验一下。然后就是优化一下，你想聊什么，会的一些细节。上周主要是 AI 记账扫描这边完成了，AI 记账扫描那个操作引导流程设计，然后拼图这边完成了剩余的22个网格，还剩10个。然后格式转换这边，新增 PDF 功能模块已经开始设计。本周的话是完成新增的 PDF 功能模块的设计，格式转换。然后拼图这边把剩余的网格设计完。我上周完，拼图完成了 AI 换头像的交互流程页面设计，然后 AI 的滤镜板块的页面设计，PhotoBOSS 的话，我就是5至8个格的拍照网格排版设计。周定引导页的订阅的设计，还有开发的功能走查。本周的工作计划是拼图2.0的高级版、超级版的引导订阅页的设计以及动画规划。然后还有视频编辑板块的流程设计。我我上周是给阿西布斯的法语版和德语版圣诞图的修改，添加圣诞元素。然后完成了意大利和印尼版的上下图。也有圣诞元素，然后优化了那个英文版的上架图，就比原先还要多多3页左右，然后添加了圣诞和跨年。的元素，然后里面排版也也修改了。然后上周提交了，然后他提出了那个修改意见，也修改好了。然后音频编辑，添加了跟转换功能的四个底部弹窗，名称编辑功能的两个底部弹窗，还有其他小修改。好，本周计划是，Flash Boys 英文版上下图再做一版不同背景色、排版的优化版本。然后还有泰国、越南上下图的制作。饮品面积如果有需要修改的及时修改。好的。我这边上周主要工作内容是 Fresh Books 的一个 logo 设计，做了四个版，四个方案 logo 然后扫描记账的话，做成了墨西哥版和土耳其版，还有英文版。英文版主要是把之前的商家图优化一下，主要也做了三个不同的配色方案。然后本周的话，暂时还没有什么安排。有修改的话就修改一下。我我上周主要是完成了睡眠 APP 新功能文本英文校对工作，德文、墨西哥西班牙文、法文、达普文、超困意大利文。本地化，炸弹 APP 新页面文本的现有千余个本地化，然后拼图 APP 新订阅页、积分制新功能英文文本校对及中文本地化。分析了市场竞品和其他相关权威产品，收集了真实源语言娱乐，初步制作了以英文和德文为主的通用语料库和专业语料库。然后本周计划是完成睡眠 APP 新功能文本的现有全语种本地化，完成拼图 APP 新订阅页、积分制新功能现有全语种本地化。继续补充完善通用娱乐和和专业娱乐产品。我上周的话主要是把那个视频，一个编辑的结果预览页做的。然后那个图片图片轮播的接入，然后里面 UI 的一些细节和逻辑的修改。那还有个导出。然后还调研上 AI 扩图的一些功能和实现方案。那这周的话，主要是把那个看 AI 扩图那个功能，还剩多少时间继续做下面，后剩余的 AI 功能。我这个的话是上周做的那一个生日模板，还有宝宝模板的那一个数据。然后再还有的话，站的 APP 那个功能已经到了，在一起的部分的一个办法。这一组的话就是把女性模板拼接上。没办法哦，爸爸没办法哦。特殊需要处理的那一个模板也去如果不出意外的话，这一周应该能把它所有的模板都能处理。我上周是完成了睡眠项目的引导页最后一页，然后引导订阅页，订阅页跟挽留页。这周的话就是先对已完成的睡眠项目进行查漏补缺，然后如果没有遗漏的，然后再进行测试，半个修复。我上周的话是开始 boss 添加的5~8个普通模板的开发步骤，然后还有就是新加的一个订阅页。然后这周的话就是开发一下Freshworks 的模板。我这边上周的话是那个，就是网格拼图功能的话，那个新出的20个模板的锚点。布局功能，还有就是功能，就是功能的一个优化。它新出了不同的那个。模板就要兼容起来，就解冻可以带一点。然后这周的话，是把设计制作出的那个不同的模板，还是继续加上去。然后我这边的话，上周主要是音频 APP 的剩余页面给它绘制完了，然后将四个 tab 页面的用户交互给它加上了，还有导入搜索功能。然后这周的话主要是接入 SDK 把一些音频工具的，对应的功能给它实现。然后争取周五的话，打一个初步的版本出来，看一下。嗯。好，现在是这样子的哦，情况可能会有一点点调整。我们这边的优化，不管是 UI 这边，然后还是上架图，包括产品这边的一些工作的内容，都还是集中在之前的那些老品的优化上面。但是目前现在这个账号。也不能更新。我们现在做的这些，功能呢，就还不确定什么时间点能够去做一个更新，因为苹果这边我们也没有办法去确定。大概的时间呢，可能是下周，也可能这周，也可能要等，再等个半个月、一个月的，这个都说不清。好，那么我们现在做一个调整。怎么调呢？就是全面的去转向一个新品的开发。研发这边手头上就是可能还会有一点点的这个时间，大家手头上还有的一些事情，我觉得就是可以先做一个收尾节点，好不好？因为我们现在就是保障一个基本上，就还，就做一个收尾吧，就不要直接就半途就中断。因为还会有一点点这个产品设计这边的一个时间的空空档期，好，做这个事。然后如果说完了之后，可以先研究一下，就是几个新品，待会我讲一下几个新品。这个一个大概的，技术的一个方向啊，这些东西的一个准备。产品这边呢，就还需要加快这个进程，然后 UI 这边也是一样的，UI 这边就是能尽可能快的把手头上的这个事情做一个节点就好了，不要，就我们不，现在不再做后面一个比较长期的这种那个工作的一个一个一个开展吧，好吧？先做一个，然后 UI 这边本周基本上就尽可能的能够进到这个新品的一个设计上面来。啊，产品这边就也是加快这个进度进程。好，然后上一上一次播那个需求时候，也跟产品这边聊了一下，我们接下来有几个新品。先规划了4个。一个是那个图片编辑的，就是林慧这边基本上功能也调研差不多。然后我们也做过一个拼图的这个产品，大概的一些需，那些功能点，但这个基本上都还是比较清楚的。然后还有一个是那个AI 的那个会议记录，就是首先是一个录音，转，然后转成那个转录成那个文字，然后它可以通过 AI 的一个接口去把那个摘要啊，那些东西去提炼出来，做一个这样子的一个一个品。还有一个是密码管理。是，就是等于说是用户在这个 APP APP 上面去做他所有的这个很多，比如说网站也好，然后 APP 的这，其他 APP 的那个账号的和密码的一个管理。然后他可能会涉及到一个那种。自动填充的这个，这样的一个功能。啊，还有一个是一个AI，那个，也是跟 AI 相关。数学，就是扫扫描数学解题的这种这种助手。目前是规划这4个品。我在想的就是我们需要去尽可能的去赶一下这个进度，因为包括上午跟投放这边去，看看参加一下他们的会的时候，会会感受到投放这边的人员就集中在我们的几个老品上面去做投放。他们现在都都变成了一个人，就几个人去同时拆成不同的地区去投一个产品，就是会面临到可以投的产品不多，这个一个这样子的一个情况啊。新品这边我们要加快一下这个进度，然后也是也是，当然跟是上到那个新账号去，因为老的这边也暂时还更新不了。就是开发的这个重心我们转一下。然后这里我在想，就是包括林慧和苏丹，首先你们这边的这个产品的这个需求，就还也是要改一下。嗯，然后赶的这个同时呢，就包括 UI 这边，就尽可能的能够去进到这边来，我们就没有必要，就这这个可能就是不同的时间，特殊情况特殊处理一下哈。大家都看一下竞品，然后大概的去规划一下，我们可以开小会，就直接单独的去聊，确定。比如说我今天就先确定首页，然后几个，两三个页面。好吧，啊，就大概的是，做这这样的一个快节奏的一个方式，然后 UI 就可以去，正在这个品上面去开始做着手，做设计。那个艺璇这边和那个秀娟这边也是一样的。然后咱们那个先聊，先了解这个产品，然后这个标题文案，包括 logo 啊，这些东西，包括整个的一个上下图，我们也是就到时候直接快速的去确定一下，商家图几个页面，什么样子的内容，然后就先先先做这个设计的内容。先可以出1版、2版，这个都没问题。根据产品上了之后，就能够很快的进入到这个投放测试的一个阶阶段。嗯，再者就是到研发这边，然后如果说 UI 这边有图出来之后，基本上功能我们可以先，也是到时候开小会吧，先快速的确定一下，就是一个1.0版本，做哪些功能？大概有时间的就可以先准备一下这个项目的一个前期的准备，然后一个技术的一个想法，好吧？然后总之就是这一周开始，差不多就慢慢的全部调到新品这边来，新品的开发。还有，就基本上就是前面的那些手头上的事情，就都做一个，做一个节点嘛。李程，我在想你这边之前你你可以以那个，就是图片编辑这个产品为主。好吧，就包括你刚刚也提到的那个新的，那个拼图的那个，后面的新的那个网格，那些东西你就可以先换一换。我现在就把它，我现在就测试一下。他的问题我就把他这个拼图第一版提出来嘛。啊，对对，因为现在就是说你在在后面去做更多的这个内容的话，我们也没有办法去做更新，现在这个账号那里。就加快这个新品的这个，到时候上新的主体、新账号，也是一样的。你前面就是根据整个的，到时候跟你会一起，然后咱们聊一下，确定一个版本，然后就大概我们去规划一下这些技术性的东西。嗯。然后几个品的话。现在是4个品啊，然后咱们这边 UI 也基本上到时候思倩，还有邓凡，邓凡现在还是在做那个睡眠的一些收尾，是不是？好，这个你也差不多就收一个尾啊。时间进度列一下吧，要不就。然后这个品的话我们先搞4个，现在是校长，先把进度列一下。先把进度列一下，现在手上这边的话，拼图这边，研发现在是三个人在做吧，可能最终方斌的话可能是时间会最久，你那边的话，如果林慧这边视频的编辑不进入的话，你那边结束的话。还要把他们所有的工作全部结完，到你手上，最终会是什么时候，大概？包含测试完，测试完。基础测试完了，基础测试完和基础的 bug 调完，那可能得3周，3周吧。你这边的话就是那就拼图这个的话，3周，从这个星期开始，对吧？然后志祥和李成，你们差不多是这里都都能完成，对，对吧？所以它的另外两个功能，就是一周，两个出来。然后睡眠那边的话。大概多久时间？这可能一周到两周吧，因为可能 bug 修复那些不太好确定。1~2周，对。完成。然后现在在开发的品还有哪个？音频编辑。音频编辑。音频编辑是新新 音频大概在什么进度？音频现在是页面大概出来了，还有功能没实现。应该是要到12月底的样子。12月底，对。四种四种。嗯，好快。还有那个福特布斯2.0版本要不要继续跟？福特布斯的话，这边其实是安卓这边你要通报一下，你现在的话是新账号上面三个品现在投放情况怎么样？目前都只在苹果这边去投的，基本上整体下来每个品就2000块钱左右的消耗。转化情况目前是都不理想的。所有的总额2000是吗？投放额。对。然后所有的消耗，你的预测和情况是什么样的？三款品。因为接下来的话，你周慧中间的话，我觉得你每一期的话，这个基础的报表还有对于这个品的整体方向，你是要全部和军哥，应该啊，我觉得，就这个会议，每次4点的会议是不是？你要和军哥两个人同步完。市场的投放情况，然后如果有三款品，你对于旗下的整个市场的期望，还有功能方向，这个其实是要你们要要同步的。然后有情况的话，还是要跟产品这边再进一步，把产品迭代的方向和进程，还有就是哪个方向，就是重点方向和非重点方向。是要提前去去做一下那个。嗯。我看一下，还有还有，旁边这边三个，够不够使？现在其实就是就是这个几个品吧，另外的话就是还有一个扫描记账，那现在后续没有，暂暂时没有版本规划。这，因为其实不，这次上的对标竞品其实功能做的已经比较全了，只是看后续要往什么方向发展。像上次军哥跟我说的一个生可能会往生成发票那个方向发展。聊天分析已经，现在已经停掉了。嗯。好，这个是目前是暂停的，对。也没有在投放，对吧？那么现在的话，扫码记账和 For boss 这两个投放，每个一共都是投放2000块钱的样子。对，福多多采的多一些，差不多在3000块钱左右，少的就差2000来块钱。这两款品，市场期望值可能会是什么样？有没有？有没有跟产品和军哥这边完全对齐？你这边自己的预计预估值情况和市场分析情况是什么样的？当初我们应该是定义做这个产品的时候，有一个基础的市场定义。节点赞的。我们这两个屏目前投放才投了一个星期嘛，那从数据角度还没有太多能看的。从产品的话，我们会去，其实三方是想打算投这个先投扫描记账的，还在准备素材。这两个品的视频素材都不太好找。哎，这2万平，我们当初市场容量是在10几的。多大？多少？几十个，大概在几十个，小品小品。可能那个 Floors 稍微大一点，扫描机将这个，后来拉了一下那个数据。好像是，是是，大概4040万的样子。40万，40万还是40万呢？好像很少。两个产品。我看一下。是这样子的，我们一款品，预估对不对？我们的预估峰值，第一步预估峰值是拉到市场的10%的量级，第二步预估峰值拉到市场的20%的。的量级，也就如果是40K的样子，我们大概的话，一个月的话，就是拿8K左右，对吧？800左右，到一天的话，大概300下载了。如果是4K左右的话，那一天的话可能是100多部下载，那么分到很多个国家就很少。那么这这种话，第一步的话，核心词，你看一下核心词的那么就看核心词的提炼，还有 CPP 的主要国家投放情况什么样的？这个的话要跟相当于是 S O 这边的话，要要同步完，同步完看结果情况怎么样。如果3000块钱，你们现在单个下载成本什么样子？不记得了。所以所以开周会的话啊，我们要想到其实我们这样的一个周会的时间成本是非常昂贵的，在这里起码要站到一个小时到两个小时，所以给出来的所有的数据和信息一定是要准备充分和完整。然后下一步要明确的方向，接下来我们怎么走？如果是这个样子。40K，如果都是两个小品的样子，那我建议现在的这个面积，有数据吗？前，教研，他前五个的大概是11，150，55K。但是他有一个是一个美国非常大的一个会计类型的品，就是，功能类型不太垂直。所以其实还是小的。多少？155。这边是，加上那个大，就是比较大的那个屏，大概是155 k。 对，那个就大部分，那个就占100。这个就是50个的样子，对吧？对，垂直类型的就是50个。有450K。然后。然后他的收入的话，看一下。450克是已经是属于中品了。中品的话，如果这个的话，那我们可以可以相当于我们可以向45~90克去做了。嗯，对，有两种是免费，但是他的这个产品必须要做那个模板跟活动，就是他才会，他的收入才会高。我看了他排在前面的收入。大概有500K。就是。就是这么多经历。嗯。前5的竞品，前5的竞品。那么刚刚说的是，你是这个是2.0，还是这个是2.0，或多或少规划？2.0我已经规划完了，现在是1.0。如果说它是中品的话，那副的 boss 的话，应该是需要考虑往，就是2.0。去去走，如果它的市场容量有这么大，那么现在的话，安卓这边的话可以跟 S O 这边同步一下，你们的投放的情况什么样的？关键词，然后核心关键词的点击率是否做到了我们10%~20%？啊，这个是首先第一个值，第二个页面的转化， C P P 的制作的转化，能不能做到75%左右？或者差别有多远？在这个地方。要把这个要不把它快速的去拉齐，然后做完迭代。然后收入的情况的话，你这边的话，产品这边要同步一下子，看一下我们现在的收入情况，还有扣费情况是怎么样的。那么这个品的话，这一边是，我觉得是可以考虑往前去推进的。然后待我完了会议之后，你可以跟军哥，然后跟安卓这边的话，到时候把数据看一下，对一下。我需要看什么方向，往前去走。这个的话。扫描记账这一个的话，可以看一下竞品的情况是什么样的。如果是小品，我们看一下竞争情情况是什么样的。然后安卓在这个时候的话，以后你这边的话，周一会议的话，就是核心关键，有两个很重要的指标，核心关键词的。核心词的，还有转换和核心词的那个落地页的转化，这两个数据的话，以后稍微做一下同步。因为这样的话，你的这边的数据同步到另外的话，就产品和 CPP 这一边，还有视觉这一边，是不需要在这边做哪些迭代？特别是一些国家不达标需要的话，那你们可以从线下会议去对齐，也可以从，在这个会议上面给大家做一个信息的同步也可以，包含这一边的话，还会跟到那开发，还有 UI，是不是要往前迭代的问题。所以跟这个会议相关的内容的话，是需要同步出来的信息。好吧，这样的话你们就知道。这个品到底要不要要不要往下走？是不是？目前的情况是停留在这个地方，那么我们努力的方向这边是肯定可以往前去推进的。目前是先准备这两个品吗？还是每一个品都需要？那就你肯定是全盘要思考，然后再通过小会议形式，哪个优先，哪个排后，优先级别。但是首先的话，你们情况是要清楚的，自己手上，自己工作，拿到手上的工作一定是非常清晰的。然后特别是产品，还有你啊，还有军哥，从我们接下来执行的策略上面，一定是要一定是要准确的。啊，这是很重要的点。因为我们可能每天要做的事情很多，那我还是以轻重缓急来做，重要的一定是排在前面，对吧？所以每次的话，我建议的话是，特别是如果有些需要做信息同步和数据同步的话，产品投放，还有现在的话是军哥这边的话已经规划出来是运营这边就是相当于还有 so。页面优化这一边，那么就到时候也是一个很重要的点，那么这这几个点的话是同步联动的。你的核心关键词。不够，对不对？那是不是页面的优化要做调整？那么你的落地页的转换不够，那么落地页这边的话是不是要做迭代调整？啊，这个是要同步推进的。然后是根据市场容量大小，你去看国家的分布和排名。我们先做核心国家，核心国家也不要拉，也不要一次性拉太宽。比方说我们可能原来说过嘛，我们核心的几个国家对不对？核心的几个国家先能不能拿到量？方向是不是对的？核心关键词是不是是不是能达标的？把这几个点死磕到一定的程度，然后拿出数据出来，确定我们这个方向是对的，那我们再把那个几十种语言再铺开，如果在这里还没有做到，没有成效的话，把几十种语言铺开，我觉得可能会啊。当然不排除，就好像提示一样，我们可能在12，T1T2没有取得成绩，但是从，但是在T3上面我们是有成绩的。啊，不排除有这种可能性。那所以的话，也要根据数据调研，得出结论，然后往哪个方向走。所以这个流程是应该是由你这边的数据，然后推动产品，还有优化，这边往前去走，这是正常往前前前走的品。所以这个的话，每一次是是，甚至有时候可以考虑周一以前，就比方说周五或者周六的时间，把这个数据同步出来，然后你们讨论完之后，周一再来出这个数据也可以。或者周一上午就应该把这个东西同步出来，然后在会议上面大家知道接下来我们这个两个东西的方向往哪边走。啊，然后就有有有点往前去推进。好，这是，这这一个。那么现在呢，刚刚军哥说了一下子是。苹果现在我们账号确实遇到了一个蛮大的阻力的问题。上周的话，产品这边还有开发也开了一个小会。那么这个问题不管情况什么样的，好和不好，时间长和短，那都不影响我们整个进程往前走。啊，无非就是这个最差的这个情况，就是我们这个账号不要了，重新再换账号。那么香港的话，另外的两个公司也在注册了。那国内的话，我们还有很多开发者公司是可以独过来用的。那么现在接下来的话就是，军哥这边的话就是规划了4个品往前推进，对吧？嗯。这个困难一重接一重啊，我觉得挺好，有挑战。那么现在的话呢，音频这个是作为新品，那到时候上哪个账号？在那个，那么这个时候时间周期往前走，挪两周。CPP 这边，还有投放这边的词，核心关键词，核心关键词这个事情，看是到时候由谁来去做调整。去做确定，到时候做，上线前的准备，这个工作也是要去去做考虑的。那么睡眠的话还有1~2周，然后拼图这边的话，方斌这边可能还有3周。你现在的话，另外两位开发的话，还有一周的时间，那么这一周的时间。如果，布布斯现在是谁在负责开发？小雅。小雅在负责开发，是吧？那么现在的话，接下来，一二三四。4个品。那在开发这边的话，应该进度是跟得上的。UI 这边的进度现在是到什么程度？实现那边开始，实现是你上周的 PDF，就那一个。PDF 这周做完，然后拼图的如果不做的话，那就那几个网格也可以完成，因为产品这边原型没那么快。我这周就把 PDF 和那个拼图剩的那几个网格全部弄完，然后产品除了新圆形，这都新产品。嗯。那我估计会要调整。我们我们就不等那个完整的原型了，到时候直接小慧直接讨论确定。手画几个页面都可以，比如说首页。那可以，那就看产品的。但是我觉得产品首先这里有个点哦，所有的竞品使用。所有的功能点的用户逻辑，嗯，对不对？然后核心功能点的付费点，对吧？嗯，就是竞竞品的分析。这里这一层逻辑我觉得是一定要一定要干完的。嗯，因为你到时候你的用户使用逻辑你不清晰的话。特别是使用场景，这些特别清晰的情况下的话，你的产品设计到时候会出问题。嗯。然后另外的，UI 呢？我这边拼图的话，还有那个视频和，还有一个订阅的，还有一个动画。但是，Photoshop 的话，2.0的还没有画的。就是事件和模板的话，还可能要弄一下。反正是在拼图这边，拼图这边的话，你是视频，对不对？对。其实现在如果进入到开发流程中间的话。你的工作是可以在目前这个时候是差不多是可以结尾或者中断的，对不对？是，拼图这周可以搞完。拼图，拼图是，不如先搞不如先搞 Photo Booth。你搞 Photo Booth，现在搞完然后。拼图是视频，视频是那个你的2.0的视频吗？还是说视频编辑啊，视频编辑这一块是吧？视频编辑的话，我建议可以稍微缓一下。转到账号那个，到时候再做。你可以先做着做着试试。因为现在你们那个也不，先不搞。这是因为是高级会员跟那个，AI 机器人的两个页面，这两个页面，两个页面大概要多久？如果不做动效的话。对，这两天就可以。做通宵的话，就这周或者下周之前。下周一之前吧。负责 boss 现在如果切的话，有有工作接替吗？有啊，我原先都搞了。负责 boss 切，是吧？那就切负责 boss 吧。那就切负责 boss 吧。可以待会看一下情况是怎么样的，负责 boss 这个的话。待会产品再对一下整体数据情况是什么样的，清晰。对，清晰一下子，然后决定的采访人是什么样的。所以我们好多事情的话。还是要有明确的动向。当然，这个时间段确实我们因为账号这个事情，把我们整体的节奏和工作都打得比较凌乱。还有一个 UI 是，哦，盾牌那边。你现在是，你现在还，这周是，完结，这周完结，这周完结，你现在手上的是还有哪些东西？是睡眠的这一些吧？对。 OK 那你最，那你在这个还能够往前提吗？有多快？哈哈哈，看你能有多快。我现在是这么想啊，因为接下来的话李晨和志强这边，这一周出完，那就下一周就会出来。下周一二就会出来。当然你们也做期一下前期的准备。那么应该来说有两个 UI 能够提前出来是最好，这个星期。那可以啊，就这样来吧。我觉得就待会小会的时候，我们军哥这边的话，到时候把这4个精品，这4个新品。然后把流程和产品再对一下，然后把具体的那个对完，现在整个流程。差不多是这个样子，现在的话呢，还有一个很重要的大的环节是投放这边的话，投放这边的话还有很多事情是会需要做调整。那么大法。再把4个新品，我们看到时候基础的调研，还有时间周长，然后还有竞品分析，这些东西全部弄完，然后再切。读完这边的情况，好吧？嗯。刚才那个时间节点和那个后面的一个一个发展方向确定了吗？嗯。邓凡，你这个星期看，就是不一定要急，实时的就进入到工作中间，你可能会要留1~2天，进入到新品中间的这个调研，还有前期准备工作中间来。啊，就差不多这样子，能够接得上。那怎么安排？UI，谁接哪个屏，谁接哪个屏，我们也好提前看一下竞品嘛。AI 会议，密，那个，我在做。然后还有一个是图片编辑，密码，密码箱，还有一个是图片编辑，图片编辑。哦，你可以先确定图片编辑这一个水准度。 UI，对。我没现在是有原型没有？我上周把功能结构梳理出来，这周在搞需求文档和原型。我这样，时间节点，反正就现在的话是。那你们自己自己想，自己自己摸脖子也行，然后自己自由搭配也行。反正时间节点都在这里，这几款品的话，整体情况应该都还好。唯一的话，面临我们的就是，旗下这这后面的几款品，最大的压力不在于开发和产品这一边，最大的压力会在投放那里。它属于中大顶级别的，基本上是，特别是那个，还有另外的话，那个 AI 的数学解题，我看了一下，全是大公司。全是大公司。所以开发这一集和产品这一集，我觉得可能问题不大，那么接下来品的话，当然了，这里早期是对于投放这边的考验，然后中后期的话是对于产品还有研发这一边的考验。那接下来的话，我们产品应该都会是做的比较深的产品，相对而言是。没有其他的，你们看有什么，然后具体人员，他们把产品的，看哪个先做。然后再切，鱼丸先进来。好吧。啊，看哪个产品你先做，就先先进来。然后现在的话，其前期最早期的是产品调研和数据，还有跟直客那边的对接的数据还有收入情况，这些东西，军军哥已经在过去的两个星期里面，已经全部都做完了。啊。这一次的话，应该前期的这一些工作都比原来的产品做得会扎实一些。包含对于竞品，还有竞品公司的分析，都已经是做完了。要不就等一下，我这这这周会咱们先那个，然后等一下我再把这几个品的前面调研的一些东西整理一下。然后就看研发可能还好，UI 吧，UI 和产品，咱们一起来再过一下，然后确定一下人员。大概大家对这个产品有个初步的了解，好吧？嗯。好，那周伟选完了。那个一选这边也一起，然后子龙也一起吧。子龙到时候先看看这几个精品的一个那个翻译的一些东西。那待会咱们再再再过来，重新整理一下吧。嗯。"
//                Task {
//                    do{
//                        let result = try await requestDoubaoAISummary(content: content)
//                        
//
//                        let todoArr = result.todoList ?? []
//                        let jsonString00 = todoArr.toJSONString()
//        //                let arr = [String].fromJSONString(json!)
//                        item.todoJsonString = jsonString00
//                        
//                        print(result.todoList ?? [])
//                        print(result.summaryTitle ?? "")
//                        print(result.summaryContent ?? "")
//
//                        let summaryContentArr = result.summaryContent ?? []
//                        let jsonString01 = summaryContentArr.toJSONString()
//                        item.summaryTitle = result.summaryTitle ?? ""
//                        item.summaryContentJsonString = jsonString01
//                        
//                        print(result.chapterSummary?.first?.title ?? "")
//
//                        let jsonString02 = result.chapterSummary.toJSONString()
//                        item.chapterSummaryJsonString = jsonString02
//                        
//                        let chapter = jsonString02!.toModel(ChapterSummary.self)
//
//                        try! RecordingItemStore.shared.updateRecordingItem(item)
//                        
//                        
//                    }catch{
//                        MyLog(error)
//                    }
//                }
                
                
                if ((item.todoJsonString?.isEmpty) != nil) {
                    let vc = HomeNoteDetailViewController(recordingItem: item)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            let item = itemFolderList[indexPath.row]
            if UtitilTools.isAddFolderData(model: item) {
                let content = HomeAddFloderPopVC()
                content.delegate = self
                let popup = PopupContainerViewController(contentVC: content, height: 259.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }else{
                UserDefaultsTools.tabSelected = 0
                let vc = HomeFloderViewController(model: item)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

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


// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomeViewController:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        let item00 = FolderItemRequest(folderName: Floder, recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        
        try! FolderItemStore.shared.addFolderItem(item00)
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}

//MARK: ----------HomeMoveoutPopVCDelegate-----------
extension RecordItemCell: HomeMoveoutPopVCDelegate {
    func updateTableViewData(){
        delegate?.reloadTableData()
    }
}

//MARK: ----------RecordItemCellDelegate-----------
extension HomeViewController: RecordItemCellDelegate {
    func reloadTableData(){
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}

//MARK: ----------RecordSecendItemCellDelegate-----------
extension HomeViewController: RecordSecendItemCellDelegate {
    func reloadSecendTableData(){
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}

@objc protocol RecordItemCellDelegate: AnyObject {
    func reloadTableData()
}

class RecordItemCell: SuperTableViewCell {
    weak var delegate: RecordItemCellDelegate?
    private var itemModel:RecordingItem? = nil
    private var isInFolder:Bool = false
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    var hitTestInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
                if isInFolder {
                    
                    var itemListData:[PopItemModel] = []
                    if model.isFavorite {
                        itemListData = HomeConfigData.getMoveOutFolderUnFavoriteData()
                    }else{
                        itemListData = HomeConfigData.getMoveOutFolderData()
                    }
                    let content = HomeMoveoutPopVC(itemList: itemListData,recordingItem: itemModel!)
                    content.delegate = self
                    let popup = PopupContainerViewController(contentVC: content, height: 564.h)
                    content.dismissAction = { [self] in
                        popup.dismissSelf()
                        delegate?.reloadTableData()
                    }
                    UIApplication.topViewController()?.present(popup, animated: false)
                }else{
                    var itemListData:[PopItemModel] = []
                    if model.isFavorite {
                        itemListData = HomeConfigData.getHomeMoreUnFavoriteData()
                    }else{
                        itemListData = HomeConfigData.getHomeMoreData()
                    }
                    let content = HomePopViewController(itemList: itemListData,recordingItem: itemModel!)
                    let popup = PopupContainerViewController(contentVC: content, height: 462.h)
                    content.dismissAction = { [self] in
                        popup.dismissSelf()
                        delegate?.reloadTableData()
                    }
                    UIApplication.topViewController()?.present(popup, animated: false)
                }
            }
        }
    }
    private lazy var favoriteImageV = UIImageView().image(Asset.homeFavorite.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var typeImageV = UIImageView().image(Asset.homeType00.image)
    private lazy var dateL = UILabel().text("Apr 10,2025 11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: hitTestInsets)
        return largerBounds.contains(point)
    }
    
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView,favoriteImageV])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,typeImageV,dateL])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }
        
        typeImageV.snp.makeConstraints { make in
            make.width.height.equalTo(16.h)
            make.left.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(4.h)
        }
        
        favoriteImageV.snp.makeConstraints { make in
            make.width.height.equalTo(22.h)
            make.left.equalTo(bgView.snp.left).offset(-4.h)
            make.top.equalTo(bgView.snp.top).offset(-4.h)
        }
        
        dateL.snp.makeConstraints { make in
            make.left.equalTo(typeImageV.snp.right).offset(4.w)
            make.right.equalTo(titleL)
            make.top.equalTo(typeImageV)
            make.height.equalTo(15.h)
        }
    }
    
    func configure(with item: RecordingItem) {
        itemModel = item
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            titleL.text(item.recordName)
            dateL.text(timestampToFormattedString(item.updateTime))
            if item.recordType == 0 {
                typeImageV.image(Asset.homeType00.image)
            }else if item.recordType == 1{
                typeImageV.image(Asset.homeType01.image)
            }
            if item.isFavorite {
                favoriteImageV.hidden(false)
            }else{
                favoriteImageV.hidden(true)
            }
            typeImageV.hidden(false)
            dateL.hidden(false)
            iconImageV.image(Asset.homeNote.image)
            if item.handleType == -1{
                iconImageV.image(Asset.noteError.image)
            }
        }
    }
    
    func configure(with item: RecordingItem,isInFolder:Bool) {
        itemModel = item
        self.isInFolder = isInFolder
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            titleL.text(item.recordName)
            dateL.text(timestampToFormattedString(item.updateTime))
            if item.recordType == 0 {
                typeImageV.image(Asset.homeType00.image)
            }else if item.recordType == 1{
                typeImageV.image(Asset.homeType01.image)
            }
            if item.isFavorite {
                favoriteImageV.hidden(false)
            }else{
                favoriteImageV.hidden(true)
            }
            typeImageV.hidden(false)
            dateL.hidden(false)
            iconImageV.image(Asset.homeNote.image)
            if item.handleType == -1{
                iconImageV.image(Asset.noteError.image)
            }
        }
    }

    /// 时间戳转：Apr 10,2025 10:30 am这种格式的时间
    public func timestampToFormattedString(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd, yyyy  hh:mm a"   // Apr 10, 2025  10:30 AM
        return formatter.string(from: date).lowercased() // am/pm 变为小写
    }
}

@objc protocol RecordSecendItemCellDelegate: AnyObject {
    func reloadSecendTableData()
}
class RecordSecendItemCell: SuperTableViewCell {
    var hitTestInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    weak var delegate: RecordSecendItemCellDelegate?
    private var itemModel:FolderItem? = nil
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 1 {
                var itemListData:[PopItemModel] = HomeConfigData.getHomeFloderData()
                let content = HomeFloderPopViewController(itemList: itemListData,folderItem: model)
                let popup = PopupContainerViewController(contentVC: content, height: 319.h)
                content.dismissAction = { [self] in
                    popup.dismissSelf()
                    delegate?.reloadSecendTableData()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }
        }
    }
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var noteNumberL = UILabel().text("0").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: hitTestInsets)
        return largerBounds.contains(point)
    }
    
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,noteNumberL])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }
        
        noteNumberL.snp.makeConstraints { make in
            make.left.equalTo(titleL.snp.left).offset(0.w)
            make.right.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(5.h)
            make.height.equalTo(15.h)
        }

    }
    
    func configure(with item: FolderItem) {
        itemModel = item
        if UserDefaultsTools.tabSelected == 1 {
            iconImageV.image(Asset.floder.image)
            noteNumberL.hidden(false)
            let fileCount = RecordingItemStore.shared.fileCount(in: item.recordFolderId!)
            noteNumberL.text("\(fileCount)" + " " + L10n.notes)
            if UtitilTools.isAddFolderData(model: item) {
                titleL.snp.remakeConstraints { make in
                    make.left.equalTo(iconImageV.snp.right).offset(10.w)
                    make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(17.h)
                }
                moreImageV.snp.remakeConstraints { make in
                    make.width.height.equalTo(28.h)
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().offset(-16.w)
                }
                titleL.text(L10n.newFolder)
                noteNumberL.hidden(true)
                moreImageV.image(Asset.addFloders.image)
                bgView.cornerRadius = 14.h
                bgView.lineWidth = 1
                bgView.strokeColor = kkColorFromHex(kkMainTextColor)
                bgView.backgroundColor = kkColorFromHexWithAlpha("FFFFFF", 0.5)
            }else{
                titleL.snp.remakeConstraints { make in
                    make.left.equalTo(iconImageV.snp.right).offset(10.w)
                    make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                    make.top.equalToSuperview().offset(16.h)
                    make.height.equalTo(17.h)
                }
                moreImageV.snp.remakeConstraints { make in
                    make.width.height.equalTo(18.h)
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().offset(-16.w)
                }
                titleL.text(item.folderName)
                moreImageV.image(Asset.moreRight.image)
                bgView.cornerRadius = 14.h
                bgView.lineWidth = 1
                bgView.strokeColor = .white
                bgView.backgroundColor = kkColorFromHexWithAlpha("FFFFFF", 1)
            }
        }
    }
}


class RecordItemDemoCell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var dateL = UILabel().text("Apr 10,2025   11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    private lazy var tryL = UILabel().text(L10n.tryNow).hnFont(size: 10.h, weight: .medium).color(kkColorFromHex(kkMainColor)).cornerRadius(13.h).border(width: 1, color: kkColorFromHex(kkMainColor)).centerAligned()
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,titleL,dateL,tryL])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        tryL.snp.makeConstraints { make in
            make.width.equalTo(60.w)
            make.height.equalTo(26.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(tryL.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }

        dateL.snp.makeConstraints { make in
            make.left.equalTo(titleL.snp.left)
            make.right.equalTo(tryL.snp.left).offset(-4.w)
            make.top.equalTo(titleL.snp.bottom).offset(4.h)
            make.height.equalTo(15.h)
        }
        
        bgView.addGradientBackground(colors: [kkColorFromHex("D4E4FF"),kkColorFromHex("BAD6FF")], direction: .bottomLeftToTopRight)

    }
    
    func configure(with item: RecordingItem) {
        titleL.text(L10n.welcome)
        dateL.text(L10n.discoverAllFeatureswithThisNote)
        tryL.text(L10n.tryNow)
    }
}



//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController:TabViewDelegate {
    func tabClickItemIndex(_ index: Int) {
        topview.updateData(searchText: "")
        UserDefaultsTools.tabSelected = index
        if index == 0 {
            try! RecordingItemStore.shared.removeDuplicateRecordingItemKeepLast()
            let items = try! RecordingItemStore.shared.fetchAllRecordingItem()
            itemList = items
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }else if index == 1 {
            try! FolderItemStore.shared.removeDuplicateFolderItemKeepLast()
            let items = try! FolderItemStore.shared.fetchAllFolderOutAllNotesItem(isContainerLast: true)
            itemFolderList = items
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }else if index == 2 {
            try! RecordingItemStore.shared.removeDuplicateRecordingItemKeepLast()
            let items = try! RecordingItemStore.shared.fetchAllRecordingItem(isFavorite: true)
            itemList = items
            emptyAddView.refreshData(emptyImage: Asset.sectionEmptyAdd.image, emptyStr: L10n.noItemsSavedYet)
            emptyAddView.delegate = self

        }
        tableView.reloadData()
        listDataisEmpty()
    }
    
    func listDataisEmpty(){
        if UserDefaultsTools.tabSelected == 0 {
            if itemList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(true)
                emptyView.hidden(false)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }else if UserDefaultsTools.tabSelected == 1 {
            if itemFolderList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(true)
                emptyView.hidden(false)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }else {
            if itemList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(false)
                emptyView.hidden(true)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }
    }
}

// MARK: -  =====================SectionEmptyAddViewDelegate=========================
extension HomeViewController:SectionEmptyAddViewDelegate {
    func addANoteClick(){
        MyLog("addANoteClick")
        let iLists = try! RecordingItemStore.shared.searchByKeyword(searchText)
        if iLists.isEmpty {
            let content = CenterClickPopViewController()
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight,isMiddle: true)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                searchText = ""
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else{
            let content = HomeAddNotePopViewController(model: nil,searchText: searchText)
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                searchText = ""
                tabClickItemIndex(UserDefaultsTools.tabSelected)
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }
    }
}


