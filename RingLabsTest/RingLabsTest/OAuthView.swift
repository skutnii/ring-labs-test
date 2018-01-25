//
//  OAuthView.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit
import WebKit

class OAuthView: UIView {
    
    lazy var webView: WKWebView = {
        [unowned self] in
        let view = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        self.addSubview(view)
        return view
    } ()
    
    var onCancel: (() -> ())?
    var onDone: (() -> ())?
    
    var title: String = "" {
        didSet {
            setup(toolbar: toolbar)
        }
    }
    
    @objc private func done() {
        onDone?()
    }
    
    lazy var doneItem: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    } ()
    
    @objc private func cancel() {
        onCancel?()
    }
    
    lazy var cancelItem: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    } ()
    
    private func setup(toolbar: UIToolbar) {
        toolbar.barTintColor = UIColor.white
        let titleItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [self.cancelItem, space1, titleItem, space2, self.doneItem]
    }

    lazy var toolbar: UIToolbar = {
        [unowned self] in
        var tb = UIToolbar()
        self.setup(toolbar: tb)
        self.addSubview(tb)
        return tb
    } ()
    
    let toolbarHeight: CGFloat = 60.0
    
    override func layoutSubviews() {
        let toolbarFrame = CGRect(origin: CGPoint(x: 0, y: 0),
                                  size:CGSize(width: bounds.size.width, height: toolbarHeight))
        toolbar.frame = toolbarFrame
        
        var contentFrame = bounds
        contentFrame.origin = CGPoint(x: 0, y: bounds.origin.y + toolbarFrame.size.height)
        contentFrame.size = CGSize(width: bounds.size.width, height: bounds.size.height - toolbarFrame.size.height)
        webView.frame = contentFrame
    }
    
    var url : URL? {
        set(anURL) {
            guard nil != anURL else {
                return
            }
            
            let request = URLRequest(url: anURL!)
            webView.load(request)
        }
        
        get {
            return webView.url
        }
    }
}
