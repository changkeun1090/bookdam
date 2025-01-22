//
//  DisplayModeVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import UIKit

final class DisplayModeVC: UIViewController {
    
    // MARK: - Properties
    private let userDefaults = UserDefaultsManager.shared
    
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
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "디스플레이 모드"
        view.backgroundColor = Constants.Colors.mainBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension DisplayModeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DisplayMode.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mode = DisplayMode.allCases[indexPath.row]
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = mode.title
        cell.contentConfiguration = configuration
        
        cell.accessoryType = mode == userDefaults.displayMode ? .checkmark : .none
        cell.backgroundColor = Constants.Colors.subBackground
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DisplayModeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMode = DisplayMode.allCases[indexPath.row]
        userDefaults.displayMode = selectedMode
        tableView.reloadData()
    }
}
