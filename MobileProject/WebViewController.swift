//
//  WebViewController.swift
//  MobileProgect
//
//  Created by 于晓杰 on 2020/11/13.
//  Copyright © 2020 于晓杰. All rights reserved.
//

import UIKit
@preconcurrency import WebKit

enum WebViewType {
    case URLLink
    case ProtocolInfo
    case UseTerms
}

class WebViewController: SuperViewController {
    var titleStr: String?
    var urlStr: String?
    var webViewType: WebViewType = .URLLink
    
    //MARK: ----------懒加载-----------
    private lazy var progressView: UIView = {
        let progressView = UIView().backgroundColor(.gray)
        return progressView
    }()
    private lazy var webView: WKWebView = {
        let webView = WKWebView.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        webView.scrollView.scrollsToTop = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleStr
        
        switch webViewType {
        case .ProtocolInfo:
            webView.load(URLRequest.init(url: URL.init(string: "https://admin.tayue.com/Privacy_Policy.html".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
        case .UseTerms:
            webView.load(URLRequest.init(url: URL.init(string: "https://admin.tayue.com/Terms_of_Service.html".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
        default:
            if urlStr != nil {
                guard let url = URL.init(string: urlStr!) else {
                    return
                }
                webView.load(URLRequest.init(url: url))
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.setCurrentOrientation(.portrait)
    }
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    override func setUpUI() {
        super.setUpUI()
        
        view.backgroundColor = .white
        view.addChildView([progressView, webView])
        progressView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(0)
        }
        
        webView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
        }
        
        view.bringSubviewToFront(progressView)
    }
    private func startLoadProgressAnimation() {
        progressView.snp.updateConstraints { (make) in
            make.width.equalTo(0)
        }
        progressView.isHidden = false
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.progressView.snp.updateConstraints { (make) in
                make.width.equalTo(kkScreenWidth * 0.7)
            }
        } completion: { (finish) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.progressView.snp.updateConstraints { (make) in
                        make.width.equalTo(kkScreenWidth * 0.95)
                    }
                }
            })
        }
    }
    private func endLoadProgressAnimation() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.progressView.snp.updateConstraints { (make) in
                make.width.equalTo(kkScreenWidth * 0.99)
            }
        } completion: { [weak self] (finish) in
            self?.progressView.isHidden = true
        }
    }
}
//MARK: ----------KVO-----------
extension WebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            return
        }
        if keyPath == "title" {
            if titleStr == nil {
                navigationItem.title = webView.title?.centerSuidScanfStr(20)
            } else {
                navigationItem.title = titleStr
            }
            return
        }
    }
}
//MARK: ----------WKUIDelegate,WKNavigationDelegate-----------
extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    //开始请求
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        startLoadProgressAnimation()
    }
    //导航完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        endLoadProgressAnimation()
    }
    //导航失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        endLoadProgressAnimation()
    }
    //页面跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    //页面跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}
