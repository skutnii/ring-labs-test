//
//  Post.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class Post : Thing {
    
    static let kind = "t3"
    
    var author: String = ""
    var date: Date? = nil
    var title: String = ""
    var commentCount: Int = 0
    var thumbnail: WebImage?
    var preview: WebImage?
    
    override func update(with data: Thing.Raw) {
        author = JSQ(data, "/author") as? String ?? ""
        
        let utcTimestamp = JSQ(data, "/created_utc") as? TimeInterval ?? 0
        date = Date(timeIntervalSince1970:utcTimestamp)
        
        title = JSQ(data, "/title") as? String ?? ""
        commentCount = JSQ(data, "/num_comments") as? Int ?? 0
        
        let thumbLink = JSQ(data, "/thumbnail") as? String ?? "default"
        if (thumbLink != "default") {
            let thumbUrl = URL(string: thumbLink)
            if (nil != thumbUrl) {
                thumbnail = WebImage(thumbUrl!)
            }
        }
        
        let previewSource = JSQ(data, "/preview/images/[0]/source/url") as? String
        if (nil != previewSource) {
            let url = URL(string:previewSource!)
            if (nil != url) {
                preview = WebImage(url!)
            }
        }
    }
}
