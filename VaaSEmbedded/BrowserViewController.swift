//
//  BrowserViewController.swift
//  VaaSEmbedded
//
//  Created by Brian Keane on 1/26/21.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var goButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        let url = URL(string: textField.text!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
