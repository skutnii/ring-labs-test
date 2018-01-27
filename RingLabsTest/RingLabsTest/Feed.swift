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
    
    private static var cache: URL {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] + "/top.json"
            return URL(fileURLWithPath:path)
        }
    }
    
    static var cached : Feed = {
        let data = try? Data(contentsOf:cache)
        guard nil != data else {
            return Feed()
        }
        
        do {
            let raw = try JSONSerialization.jsonObject(with: data!, options: []) as? Thing.Raw
            guard nil != raw else {
                return Feed()
            }
            
            return Feed(raw: raw!)
        } catch {
            return Feed()
        }
    } ()
    
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
        return Fetch.from("https://www.reddit.com/top.json").then {
            res in
            let data = res as? Data
            guard nil != data else {
                return cached
            }
            
            do {
                let value = try JSONSerialization.jsonObject(with: data!, options: [])
                let raw = value as? Raw
                guard nil != raw else {
                    return Promise.reject("Invalid data format")
                }
                
                do {
                    //Don't let cache errors mess with flow, so catching separately
                    try data!.write(to: cache)
                } catch {
                    print("Cache error")
                }
                
                cached = Feed(raw: raw!)
                return cached
            } catch {
                return cached
            }
            
        } .then {
            res in
            for post in cached.posts {
                _ = post.thumbnail?.fetch()
            }
            
            return res
        }
    }
}
