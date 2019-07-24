//
//  ViewController.swift
//  Easy Web Browser
//
//  Created by Jerrick Warren on 7/22/19.
//  Copyright © 2019 Jerrick Warren. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    // create webView
    var webView: WKWebView!
    
    // KVO
    var progressView : UIProgressView!
    
    // Allowed websites
    var websites = ["coinmarketcap.com",
                    "Datamish.com",
                    "Robinhood.com",
                    "Pro.coinbase.com",
                    "Gemini.com" ]

    // This is called before ViewDidLoad
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loads website
        let url = URL(string: "https://" + websites[0])!
        print(url)
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.contentScaleFactor = 0.8
        
        // MARK: Toolbar Buttons
        
        // Create spacer
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Create refresh
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // create forward button
//        let forward = UIBarButtonItem(barButtonSystemItem: .play, target: webView, action:      #selector(webView.goForward))
        
        // create forward button
        let forward = UIBarButtonItem(image:#imageLiteral(resourceName: "forward.png") , style: .plain, target: webView, action: #selector(webView.goForward))
        
        
        // create backward button
        let backward = UIBarButtonItem(image:#imageLiteral(resourceName: "backward.png") , style: .done, target: webView, action: #selector(webView.goBack))
        

        // Toolbar Buttons Array
        toolbarItems = [progressButton, spacer, backward, spacer, forward, spacer, refresh]
        
        navigationController?.isToolbarHidden = false
        
        // Add the observer
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new
            , context: nil)
        
        // Add actionsheet
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    }

    @objc func openTapped(){
        
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)

        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
//        ac.addAction(UIAlertAction(title: "Datamish.com", style: .default, handler: openPage))
//
//        ac.addAction(UIAlertAction(title: "Robinhood.com", style: .default, handler: openPage))
//
//        ac.addAction(UIAlertAction(title: "Pro.coinbase.com", style: .default, handler: openPage))
//
//        ac.addAction(UIAlertAction(title: "Gemini.com", style: .default, handler: openPage))
//

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction){
        
        guard let actionTitle = action.title else { return }
        
        guard let url = URL(string: "https://" + actionTitle) else { return }
        
        webView.load(URLRequest(url: url))
    }
    
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress"{
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website.lowercased()) {
                    decisionHandler(.allow)
                    print(host)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
    }
}

