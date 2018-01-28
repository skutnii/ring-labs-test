//
//  Feed.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/26/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Feed : Thing {
    
    static let kind = "Listing"
    
    enum Err: Error {
        case JSON
    }
    
    
    convenience init() {
        self.init(kind: Feed.kind)
    }
    
    static let Link = "https://www.reddit.com/top.json"
    
    class func fetch(from link: String) -> Promise {
        return Fetch.json(link).then {
            value in
            let raw = value as? Raw
            guard nil != raw else {
                return Promise.reject("Invalid data format")
            }
            
            let feed = Feed(raw: raw!)
            for post in feed.posts {
                _ = post.thumbnail?.fetch()
            }
            
            return feed
        }
    }
    
    class func getTop(limit: Int) -> Promise {
        return fetch(from:"\(Link)?limit=\(limit)")
    }
    
    class Keys {
        static let children = "children"
        static let kind = "kind"
        static let before = "before"
        static let after = "after"
    }
    
    var posts : [Post] = []
    var before: String?  = nil
    var after: String? = nil
    
    override func update(with data: Thing.Raw) {
        before = data[Keys.before] as? String
        after = data[Keys.after] as? String
        
        let children = data[Keys.children] as? [Thing.Raw]
        guard nil != children else {
            return
        }
        
        posts = Post.parse(array:children!)
    }
    
    override var data : Thing.Raw {
        get {
            var values : Thing.Raw = [
                Keys.children: posts.map {
                    post in return post.json
                }
            ]
            
            values[Keys.before] = before
            values[Keys.after] = after
            
            return values
        }
    }
    
    func getNext(limit:Int) -> Promise {
        guard nil != self.after else {
            return Promise.resolve(nil)
        }
        
        return Feed.fetch(from:"\(Feed.Link)?before=\(after!)&limit=\(limit)")
    }
}
