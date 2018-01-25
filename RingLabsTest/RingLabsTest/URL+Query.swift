//
//  URL+Query.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

extension URL {
    //initialize an URL with root and query dictionary
    init?(_ root: String, _  query: [String: String] = [:]) {
        var q = ""
        var first = true
        for (key, value) in query {
            if (first) {
                first = false
            } else {
                q += "&"
            }
            
            q += "\(key)=\(value)"
        }
        
        var link = root
        if (q.count > 0) {
            link += "?\(q)"
        }
        
        self.init(string:link)
    }
}
