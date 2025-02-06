//
//  MoreVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import UIKit
import MessageUI
import StoreKit

// MARK: - Section Model
enum MoreSection: Int, CaseIterable {
    case setting
    case feedback
    case appInfo
    
    var title: String? {
        switch self {
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
        case .setting:
            return [.tagManagement, .displaySetting]
        case .feedback:
            return [.sendFeedback, .sendEmail, .appReview]
        case .appInfo:
            return [.notice, .frequently]
        }
    }
}

// MARK: - Row Model
enum MoreRow {
    case tagManagement
    case displaySetting
    case sendFeedback
    case sendEmail
    case appReview
    case frequently
    case cloudSnyc
    case notice
    
    
    var title: String {
        switch self {
        case .tagManagement:
            return "태그 관리"
        case .displaySetting:
            return "화면 테마"
        case .sendFeedback:
            return "의견 남기기"
        case .sendEmail:
            return "메일 보내기"
        case .appReview:
            return "평점 남기기"
        case .notice:
            return "공지 사항"
        case .frequently:
            return "자주하는 질문"
        case .cloudSnyc:
            return "데이터 동기화"
        }
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .displaySetting, .tagManagement:
            return .disclosureIndicator
        default:
            return .none
        }
    }
}

extension Bundle {
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    var fullVersion: String {
        return "\(appVersion) (\(buildNumber))"
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
        
        // Add footer view
        let footerLabel = UILabel()
        footerLabel.text = "버전 \(Bundle.main.appVersion)"
        footerLabel.font = Constants.Fonts.smallBody
        footerLabel.textColor = Constants.Colors.subText
        footerLabel.textAlignment = .right
        
        // Add padding to footer
        let footerContainer = UIView()
        footerContainer.addSubview(footerLabel)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerLabel.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: Constants.Layout.extraSmMargin),
            footerLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: Constants.Layout.layoutMargin),
            footerLabel.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            footerLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        tableView.tableFooterView = footerContainer
        
        
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.layoutMargin),
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
        
        case .sendEmail:
            handleEmail()
            
        case .sendFeedback:
            handleFeedback()
            
        case .appReview:
            handleAppReview()
            
        case .notice:
            handleNotice()
            
        case .frequently:
            handleFrequently()
            
        default:
            break
        }
        
    }

}

extension MoreVC {
    
    private func handleFrequently() {
        let link = "https://abounding-plate-68e.notion.site/18536d45e5408083acfde9507e047f3b?pvs=4"
        if let url = URL(string: link) {
            presentSafariVC(with: url)
        }
    }
    
    private func handleNotice() {
        let link = "https://abounding-plate-68e.notion.site/19036d45e5408051a97cda4b4b53c1e9?pvs=4"
        if let url = URL(string: link) {
            presentSafariVC(with: url)
        }
    }
    
    private func handleAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func openAppStorePage(appId: String) {
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleFeedback() {
        let link = "https://forms.gle/ZnZBKqYQqwuevnHWA"
        if let url = URL(string: link) {
            presentSafariVC(with: url)
        }
    }
    
    private func handleCloudSync() {
        
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

extension MoreVC: MFMailComposeViewControllerDelegate {
    
    private func handleEmail() {
        // First check if device can send emails
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // Configure the email content
            mailComposer.setToRecipients(["kenz3tudio@gmail.com"])
            mailComposer.setSubject("[책담] 문의사항")
            
            // You might want to add some default content or device information
            let emailBody = """
                        
            ----------
            App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            Device: \(UIDevice.current.model)
            iOS Version: \(UIDevice.current.systemVersion)
            """
            
            mailComposer.setMessageBody(emailBody, isHTML: false)
            
            // Present the mail composer
            present(mailComposer, animated: true, completion: nil)
        } else {
            // Handle the case when email is not configured
            showEmailNotAvailableAlert()
        }
    }
    
    // Add this method to handle completion of email sending
    func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
        // Dismiss the mail composer
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.showAlert(title: "메일 전송 완료", message: "메일이 성공적으로 전송되었습니다.")
            case .failed:
                self.showAlert(title: "메일 전송 실패", message: "메일 전송에 실패했습니다. 다시 시도해주세요.")
            default:
                break
            }
        }
    }
    
    // Helper method to show alert when email is not available
    private func showEmailNotAvailableAlert() {
        let alert = UIAlertController(
            title: "이메일을 보낼 수 없습니다",
            message: "이 기기에서 이메일 기능을 사용할 수 없습니다. 이메일 설정을 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // Helper method for showing alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

}
