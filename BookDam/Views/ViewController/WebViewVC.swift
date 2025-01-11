//
//  WebViewVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/8/25.
//

import WebKit

class WebViewController: UIViewController {
    
    private let webView: WKWebView
    
    init(url: URL) {
        self.webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
        loadWebPage(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = .none
        
        let backButton = UIBarButtonItem()
        
        navigationController?.navigationBar.tintColor = Constants.Colors.accent

        backButton.title = "돌아가기"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func loadWebPage(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
