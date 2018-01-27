//
//  FullImageController.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/27/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit
import WebKit

class FullImageController: UIViewController {
    
    var image: WebImage? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        let url = image?.url
        if (nil != url) {
            let request = URLRequest(url: url!)
            contentView.load(request)
        }
    }
    
    var contentView : WKWebView {
        return view as! WKWebView
    }
    
    override func loadView() {
        view = WKWebView(frame: .zero,  configuration:WKWebViewConfiguration())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
