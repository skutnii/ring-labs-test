//
//  Feed.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Feed {
    var posts : [Post] = []
    var timestamp: Date?
    
    static var cached: Feed? = nil
    
    class func sync(_ onSync: @escaping (Feed) -> ()) {
        
    }
    
    init(posts: [Post], timestamp: Date) {
        self.posts = posts
        self.timestamp = timestamp
    }
    
    convenience init() {
        self.init(posts: [], timestamp: Date())
    }
    
    typealias Raw = [String: Any]
    
    static let POSTS = "posts"
    static let TS = "timestamp"
    
    convenience init(raw: Raw) {
        let ts = (raw[Feed.TS] as? Date) ?? Date()
        let rawPosts = (raw[Feed.POSTS] as? [Post.Raw]) ?? []
        let posts = rawPosts.map() { data in
            return Post(data)
        }
        
        self.init(posts: posts, timestamp: ts)
    }
    
    var data : Raw {
        get {
            return [
                Feed.TS: self.timestamp,
                Feed.POSTS: self.posts.map() {
                    post in
                    return post.data
                }
            ]
        }
    }
}
