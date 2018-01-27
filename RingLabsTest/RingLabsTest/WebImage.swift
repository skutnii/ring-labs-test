//
//  WebImage.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/27/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation
import UIKit

class WebImage : Observable {
    
    private lazy var _scope = { [unowned self] in return WatchScope(self) }()
    var watch: WatchScope {
        get {
            return _scope
        }
    }
    
    let url: URL
    var image: UIImage? = nil {
        didSet {
            _scope.notify()
        }
    }
    
    func fetch() -> Promise {
        return Fetch.url(url).then {
            result in
            let data = result as? Data
            guard nil != data else {
                return self
            }
            
            self.image = UIImage(data:data!)
            return self
        }
    }
    
    init(_ url: URL) {
        self.url = url
    }
}
