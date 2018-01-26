//
//  Feed.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/26/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Feed : Thing {
    var posts : [Post] = []
    let timestamp = Date()
    
    static let CHILDREN = "children"
    static let kind = "Listing"
    
    static var cached = Feed()
    
    convenience init() {
        self.init(kind: Feed.kind)
    }
    
    override func update(with data: Thing.Raw) {
        let children = data[Feed.CHILDREN] as? [Thing.Raw]
        guard nil != children else {
            return
        }
        
        posts = Post.parse(array:children!)
    }
    
    class func sync() -> Promise {
        return HTTP.fetchJSON("https://www.reddit.com/top.json").then {
            value in
            let raw = value as? Raw
            guard nil != raw else {
                return Promise.reject("Invalid data format")
            }
            
            cached = Feed(raw: raw!)
            return cached
        }
    }
}
