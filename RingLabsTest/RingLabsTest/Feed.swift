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
    
    private static var cache: URL {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] + "/top.json"
            return URL(fileURLWithPath:path)
        }
    }
    
    private static var _cached : Feed? = nil
    
    enum Err: Error {
        case JSON
    }
    
    static var cached : Feed {
        get {
            if (nil == _cached) {
                do {
                    let data = try Data(contentsOf:cache)
                    
                    let raw = try JSONSerialization.jsonObject(with: data, options: []) as? Thing.Raw
                    guard nil != raw else {
                        throw Err.JSON
                    }
                    
                    _cached = Feed(raw: raw!)
                } catch {
                    _cached = Feed()
                }
            }
            
            return _cached!
        }
        
        set(feed) {
            _cached = feed
            guard nil != _cached else {
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: _cached!.json, options: [])
                try data.write(to: cache)
            } catch {
                print("Feed cache error")
            }
       }
    }
    
    convenience init() {
        self.init(kind: Feed.kind)
    }
    
    class func sync() -> Promise {
        return Fetch.json("https://www.reddit.com/top.json?limit=50").then {
            value in
            let raw = value as? Raw
            guard nil != raw else {
                return Promise.reject("Invalid data format")
            }
            
            cached = Feed(raw: raw!)
            return cached
        } .then {
            res in
            for post in cached.posts {
                _ = post.thumbnail?.fetch()
            }
            
            return res
        }
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
            return [
                Keys.children: posts.map {
                    post in return post.json
                }
            ]
        }
    }
}
