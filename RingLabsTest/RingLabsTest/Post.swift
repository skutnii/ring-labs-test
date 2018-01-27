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
    
    class Keys {
        static let author = "author"
        static let created = "created_utc"
        static let title = "title"
        static let thumbnail = "thumbnail"
        static let preview = "preview"
        static let images = "images"
        static let source = "source"
        static let numComments = "num_comments"
        static let url = "url"
    }
    
    override func update(with data: Thing.Raw) {
        author = JSQ(data, Keys.author) as? String ?? ""
        
        let utcTimestamp = JSQ(data, Keys.created) as? TimeInterval ?? 0
        date = Date(timeIntervalSince1970:utcTimestamp)
        
        title = JSQ(data, "/title") as? String ?? ""
        commentCount = JSQ(data, Keys.numComments) as? Int ?? 0
        
        let thumbLink = JSQ(data, Keys.thumbnail) as? String ?? "default"
        if (thumbLink != "default") {
            let thumbUrl = URL(string: thumbLink)
            if (nil != thumbUrl) {
                thumbnail = WebImage(thumbUrl!)
            }
        }
        
        let previewQuery =  "/\(Keys.preview)/\(Keys.images)/[0]/\(Keys.source)/\(Keys.url)"
        let previewSource = JSQ(data, previewQuery) as? String
        if (nil != previewSource) {
            let url = URL(string:previewSource!)
            if (nil != url) {
                preview = WebImage(url!)
            }
        }
    }
    
    override var data : Thing.Raw {
        get {
            var values = super.data
            values[Keys.author] = author
            values[Keys.created] = date?.timeIntervalSince1970
            values[Keys.title] = title
            values[Keys.numComments] = commentCount
            values[Keys.thumbnail] = thumbnail?.url.absoluteString ?? "default"
            
            if (nil != preview) {
                values[Keys.preview] = [
                    Keys.images: [
                        [
                            Keys.source: [
                                Keys.url:preview!.url.absoluteString
                            ]
                        ]
                    ]
                ]
            }
            
            return values
        }
    }
}
