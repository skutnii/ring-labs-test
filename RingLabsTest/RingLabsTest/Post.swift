//
//  Post.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Post : Thing {
    
    static let AUTHOR = "author"
    var author: String = ""
    
    static let DATE = "created_utc"
    var date: Date? = nil
    
    static let TITLE = "title"
    var title: String = ""
    
    override func update(with data: Thing.Raw) {
        author = data[Post.AUTHOR] as? String ?? ""
        
        let utcTimestamp = data[Post.DATE] as? TimeInterval ?? 0
        date = Date(timeIntervalSince1970:utcTimestamp)
        
        title = data[Post.TITLE] as? String ?? ""
    }
}
