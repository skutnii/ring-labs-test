//
//  OAuthViewController.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController {

    func onComplete(_ block: @escaping (URL?) -> ()) {
        authView.onDone = {
            [weak self] in
            block(self?.authView.url)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func onCancel(_ block: @escaping () -> ()) {
        authView.onCancel = {
            [weak self] in
            block()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func load(_ url: URL?) {
        authView.url = url
    }
    
    private var authView : OAuthView {
        get {
            return view as! OAuthView
        }
    }
    
    override func loadView() {
        view = OAuthView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var title: String? {
        didSet {
            authView.title = title ?? ""
        }
    }
    
}
