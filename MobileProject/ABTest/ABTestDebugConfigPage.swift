import UIKit

// 定义AB测试选项模型
struct ABTestOption {
    let id: String
    let name: String
    let description: String?
}

// 定义AB测试分组模型
struct ABTestGroup {
    let id: String
    let name: String
    let options: [ABTestOption]
    var selectedOptionId: String?
}

final class ABTestDebugConfigPage: UIViewController {
    var dismissHandler: (() -> Void)?

    private var testGroups: [ABTestGroup] = EventReport.ABTestType.allCases.map {
        .init(id: $0.key, name: $0.description, options: $0.infos.map {
            .init(id: $0.value, name: $0.value, description: $0.description)
        }, selectedOptionId: UserDefaults.standard.string(forKey: $0.key))
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ABTestOptionCell.self, forCellReuseIdentifier: ABTestOptionCell.reuseIdentifier)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        testGroups.insert(.init(id: AppHelper.AppHelperUserDefaultsKeys.isShowGuidView.rawValue, name: "是否走引导页", options: [.init(id: "1", name: "是", description: "去引导页"), .init(id: "0", name: "否", description: "去首页")], selectedOptionId: UserDefaults.standard.bool(forKey: AppHelper.AppHelperUserDefaultsKeys.isShowGuidView.rawValue) ? "1" : "0"), at: 0)
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "AB测试配置"

        // 设置导航栏按钮
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton

        // 添加表格视图
        view.addSubview(tableView)

        // 设置约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func saveButtonTapped() {
        // 保存选中的配置
        saveSelectedOptions()
        dismissHandler?()
        dismiss(animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismissHandler?()
        dismiss(animated: true)
    }

    private func saveSelectedOptions() {
        // 这里实现保存逻辑，例如存储到UserDefaults或发送到服务器
        for group in testGroups {
            guard let selectedId = group.selectedOptionId else { continue }
            if group.id == AppHelper.AppHelperUserDefaultsKeys.isShowGuidView.rawValue {
                UserDefaults.standard.set(selectedId == "1", forKey: group.id)
            } else if group.id == AppHelper.AppHelperUserDefaultsKeys.ABTest_delayTimeValue.rawValue {
                UserDefaults.standard.set(Double(selectedId), forKey: group.id)
            } else {
                UserDefaults.standard.set(selectedId, forKey: group.id)
            }
        }
        UserDefaults.standard.synchronize()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ABTestDebugConfigPage: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return testGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testGroups[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ABTestOptionCell.reuseIdentifier,
            for: indexPath
        ) as? ABTestOptionCell else {
            return UITableViewCell()
        }

        let group = testGroups[indexPath.section]
        let option = group.options[indexPath.row]
        let isSelected = group.selectedOptionId == option.id

        cell.configure(with: option, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return testGroups[section].name
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 更新选中状态
        let selectedOptionId = testGroups[indexPath.section].options[indexPath.row].id
        testGroups[indexPath.section].selectedOptionId = selectedOptionId

        // 刷新当前分组
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}

// 自定义选项单元格
class ABTestOptionCell: UITableViewCell {
    static let reuseIdentifier = "ABTestOptionCell"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with option: ABTestOption, isSelected: Bool) {
        titleLabel.text = option.name
        descriptionLabel.text = option.description
        accessoryType = isSelected ? .checkmark : .none
    }
}

extension EventReport.ABTestType {
    struct ABTestInfo {
        let value: String
        let description: String
    }

    var key: String {
        switch self {
        case .retrieve:
            return AppHelper.AppHelperUserDefaultsKeys.ABTest_retrieveValue.rawValue
//        case .homeAlert:
//            return AppHelper.AppHelperUserDefaultsKeys.ABTest_homeAlertValue.rawValue
        case .delayTime:
            return AppHelper.AppHelperUserDefaultsKeys.ABTest_delayTimeValue.rawValue
        }
    }

    var description: String {
        switch self {
        case .retrieve:
            return "ABTest_retrieve：挽留页AB测试是否显示挽留页"
//        case .homeAlert:
//            return "ABTest_homeAlert：首页弹窗AB测试（A评价轮播，B设置订阅页，C无弹窗）"
        case .delayTime:
            return "各营销订阅页面按钮隐藏时间（秒）"
        }
    }

    var infos: [ABTestInfo] {
        switch self {
        case .retrieve:
            return [.init(value: "YES", description: "显示挽留页"), .init(value: "NO", description: "不显示挽留页")]
//        case .homeAlert:
//            return [.init(value: "A", description: "评价轮播"), .init(value: "B", description: "设置订阅页"), .init(value: "C", description: "无弹窗")]
        case .delayTime:
            return [.init(value: "0", description: "0秒"), .init(value: "5", description: "5秒"), .init(value: "15", description: "15秒")]
        }
    }
}
