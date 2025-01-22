//
//  MoreVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import UIKit

// MARK: - Section Model
enum MoreSection: Int, CaseIterable {
    case tagManagement
    case setting
    case feedback
    case appInfo
    
    var title: String? {
        switch self {
        case .tagManagement:
            return nil
        case .setting:
            return nil
        case .feedback:
            return nil
        case .appInfo:
            return nil
        }
    }
    
    var rows: [MoreRow] {
        switch self {
        case .tagManagement:
            return [.tagManagement]
        case .setting:
            return [.displaySetting, .cloudSnyc]
        case .feedback:
            return [.notificationTime, .emailNotification, .appReview]
        case .appInfo:
            return [.frequently, .appVersion]
        }
    }
}

// MARK: - Row Model
enum MoreRow {
    case tagManagement
    case displaySetting
    case textSize
    case notificationTime
    case emailNotification
    case appReview
    case frequently
    case appVersion
    case cloudSnyc
    
    
    var title: String {
        switch self {
        case .tagManagement:
            return "모든 태그 관리"
        case .displaySetting:
            return "디스플레이 모드"
        case .textSize:
            return "텍스트 크기"
        case .notificationTime:
            return "의견 보내기"
        case .emailNotification:
            return "메일 보내기"
        case .appReview:
            return "앱 평점 남기기"
        case .frequently:
            return "자주하는 질문"
        case .cloudSnyc:
            return "iCloud 동기화 하기"
        case .appVersion:
            return "앱 버전"
        }
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .displaySetting, .textSize, .tagManagement:
            return .disclosureIndicator
        default:
            return .none
        }
    }
}

// MARK: - MoreViewController
class MoreVC: UIViewController {
    
    // MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = Constants.Colors.mainBackground
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = "돌아가기"
        navigationController?.navigationBar.tintColor = Constants.Colors.accent
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Constants.Colors.mainBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension MoreVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MoreSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = MoreSection(rawValue: section)!
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let section = MoreSection(rawValue: indexPath.section)!
        let row = section.rows[indexPath.row]
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = row.title
         
        cell.contentConfiguration = configuration
        cell.accessoryType = row.accessoryType
        cell.backgroundColor = Constants.Colors.subBackground
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MoreVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = MoreSection(rawValue: indexPath.section)!
        let row = section.rows[indexPath.row]
        
        switch row {
        case .tagManagement:
            let tagListVC = TagListVC()
            navigationController?.pushViewController(tagListVC, animated: true)
            
        case .displaySetting:
            let displayModeVC = DisplayModeVC()
            navigationController?.pushViewController(displayModeVC, animated: true)
            
        case .cloudSnyc:
            handleCloudSync()
            
        default:
            break
        }
        
    }

}

extension MoreVC {
    
    private func handleCloudSync() {
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: nil,
            message: "동기화 중...",
            preferredStyle: .alert
        )
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
                
        CloudKitManager.shared.triggerSync { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        let alert = UIAlertController(
                            title: "동기화 실패",
                            message: "iCloud 동기화 중 오류가 발생했습니다. 다시 시도해주세요.\n오류: \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(
                            title: "동기화 완료",
                            message: "iCloud 동기화가 완료되었습니다.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                                                
                        BookManager.shared.loadBooks()
                        TagManager.shared.loadTags()
                    }
                }
            }
        }
    }
}
