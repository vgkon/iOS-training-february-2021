//
//  WebHomepageController.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 8/3/21.
//

import UIKit
import WebKit

class WebHomepageController : UIViewController, WKUIDelegate {
    
    var webClosure: ((String) -> ())?
    
    var webFromSource: String?
    var homepageUrl : URL?
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to control the sheet dismissal
        self.presentationController?.delegate = self
        setupWebLabel()
        let myRequest = URLRequest(url: homepageUrl!)
        webView.load(myRequest)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        if let _ = self.presentingViewController as? MovieSceneController, let webFromSource = webFromSource {
                webClosure?(webFromSource)
        }
        self.dismiss(animated: true)
    }
    
}

fileprivate extension WebHomepageController {
    
    func setupWebLabel() {
        if let webFromSource = webFromSource {
            print ("Webpage from source: \(webFromSource)")
        } else {
            print ("Webpage wasn't delivered")
        }
    }
    
}

extension WebHomepageController : UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("will dismiss")
        if let webFromSource = webFromSource {
            webClosure?(webFromSource)
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("did dismiss")
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("did attempt to dismiss")
    }
}
