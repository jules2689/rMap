//
//  UIWebViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-26.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import UIKit

class UIWebViewController: UIViewController {
    @IBOutlet weak var webView:UIWebView?

    override func loadView() {
        super.loadView()
        self.webView?.loadRequest(URLRequest.init(url: URL.init(string: "https://airtable.com/shr6Faxv3W9slWS6a")!))
    }
}

