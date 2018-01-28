//
//  Store.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/28/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Store : Observable {
    
    private init() {
    }
    
    private var cache: URL {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            return URL(fileURLWithPath:paths[0]).appendingPathComponent("store.json")
        }
    }
    
    static let global = Store()
    
    private class Keys {
        static let posts = "posts"
    }
    
    private var _readWriteLocked = false
    private func write(){
        guard !_readWriteLocked else {
            print("Write locked")
            return
        }
        
        guard nil != _posts else {
            return
        }
        
        _readWriteLocked = true
        
        do {
            let json = [
                Keys.posts: posts.map {
                    post in return post.json
                }
            ]
            
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try data.write(to: cache)
        } catch {
            print("Store write error")
        }
        
        _readWriteLocked = false
    }
    
    private func read() {
        guard !_readWriteLocked else {
            print("Read locked")
            return
        }
        
        _readWriteLocked = true
        
        do {
            if (!FileManager.default.fileExists(atPath:cache.path)) {
                _posts = []
            } else {
                let data = try Data(contentsOf:cache)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let rawPosts = JSQ(json, Keys.posts) as? [Thing.Raw] ?? []
                _posts = Post.parse(array: rawPosts)
            }
        } catch {
            print("store read error")
            return
        }
        
        watch.notify()
        
        _readWriteLocked = false
    }
    
    var _posts : [Post]? = nil
    var posts : [Post] {
        get {
            if (nil == _posts) {
                read()
            }
            
            return _posts!
        }
    }
    
    private var _syncLocked = false
    private var feed: Feed? = nil
    
    func fetch() -> Promise {
        guard !_syncLocked else {
            return Promise.resolve(nil)
        }
        
        _syncLocked = true
        
        let isInitial = (nil == feed)
        
        if (isInitial) {
            
            let top = Feed.getTop(limit:50).then {
                result in
                let newFeed = result as? Feed
                if (nil != newFeed) {
                    self.feed = newFeed!
                    self._posts = newFeed!.posts
                    self.write()
                    self.watch.notify()
                }
                
                self._syncLocked = false
                return result
            }
            
            _ = top.rescue {
                err in
                self._syncLocked = false
                return err
            }
            
            return top
            
        } else {
            
            let next = feed!.getNext(limit:50).then {
                result in
                let newFeed = result as? Feed
                if (nil != newFeed) {
                    self.feed = newFeed!
                    self._posts!.append(contentsOf:newFeed!.posts)
                    self.write()
                    self.watch.notify()
                }
                
                self._syncLocked = false
                return result
            }
            
            _ = next.rescue {
                _ in
                self._syncLocked = false
                return nil
            }
            
            return next
        }
    }
    
    private lazy var _watch: WatchScope = { [unowned self] in
        return WatchScope(self)
    } ()
    
    var watch: WatchScope {
        get {
            return _watch
        }
    }
    
}
