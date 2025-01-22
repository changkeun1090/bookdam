//
//  TagListingVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import UIKit

final class TagListVC: UIViewController {
    
    // MARK: - Properties
    private let tagManager = TagManager.shared
    private let bookManager = BookManager.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        tableView.backgroundColor = Constants.Colors.mainBackground
        return tableView
    }()
    
    private var tags: [Tag] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var tagUsageCounts: [UUID: Int] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTagManager()
        calculateTagUsage()
        sortTagOrder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "모든 태그"
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabel = UILabel()
        headerLabel.text = "👈 목록을 스와이프하여 수정 및 삭제할 수 있습니다"
        headerLabel.font = .preferredFont(forTextStyle: .subheadline)
        headerLabel.textColor = Constants.Colors.subText
        headerLabel.numberOfLines = 0
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        tableView.tableHeaderView = headerView
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTagManager() {
        tagManager.delegate = self
        tags = tagManager.tags
    }
    
    private func calculateTagUsage() {
        tagUsageCounts.removeAll()
        
        let books = bookManager.books
        
        for book in books {
            if let bookTags = book.tags {
                for tag in bookTags {
                    tagUsageCounts[tag.id, default: 0] += 1
                }
            }
        }
    }
    
    private func sortTagOrder() {
        self.tags = tags.sorted {
            (tagUsageCounts[$0.id] ?? 0) > (tagUsageCounts[$1.id] ?? 0)
        }
    }
}

// MARK: - UITableViewDataSource
extension TagListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        let tag = tags[indexPath.row]
                  
        var configuration = UIListContentConfiguration.valueCell()
        configuration.text = tag.name
                  
        let count = tagUsageCounts[tag.id] ?? 0
        configuration.secondaryText = "\(count)"
          
        configuration.secondaryTextProperties.color = Constants.Colors.subText
          
        cell.contentConfiguration = configuration
        cell.accessoryType = .none
        cell.backgroundColor = Constants.Colors.subBackground
          
          return cell
    }
}

// MARK: - UITableViewDelegate
extension TagListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tag = tags[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            let alert = UIAlertController(
                title: "태그 삭제",
                message: "이 태그를 삭제하시겠습니까?",
                preferredStyle: .alert
            )
            
            let deleteConfirmAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self?.tagManager.deleteTag(with: tag.id)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(deleteConfirmAction)
            alert.addAction(cancelAction)
            
            self?.present(alert, animated: true)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (_, _, completion) in
            let alert = UIAlertController(title: "태그 수정", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = tag.name
                textField.placeholder = "태그 이름"
            }
            
            let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
                guard let newName = alert.textFields?.first?.text else { return }
                self?.tagManager.updateTag(id: tag.id, newName: newName)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self?.present(alert, animated: true)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

// MARK: - TagManagerDelegate
extension TagListVC: TagManagerDelegate {
    func tagManager(_ manager: TagManager, didUpdateTags tags: [Tag]) {
        self.tags = tags
        calculateTagUsage()
        sortTagOrder()
    }
    
    func tagManager(_ manager: TagManager, didDeleteTags ids: Set<UUID>) {
        calculateTagUsage()
        sortTagOrder()
    }
}
