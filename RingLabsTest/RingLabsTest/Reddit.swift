//
//  Reddit.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

//Reddit API access
class Reddit {
    static var token : String? = nil
    static let KEY = "kuAA1wW5wy3jFw"
    static let SCHEMA = "https://reddit.com"
        
    class func authorize(_ presenter: OAuthViewController) {
        let uid = UUID().description
        let authURL = URL("https://www.reddit.com/api/v1/authorize", [
            "client_id": Reddit.KEY,
            "response_type": "code",
            "state": uid,
            "redirect_uri": Reddit.SCHEMA,
            "duration": "temporary",
            "scope": "read"
        ])
        
        presenter.onCancel {
            
        }
        
        presenter.onComplete { url in
            print("URL: ", url)
        }
        
        presenter.load(authURL)
    }
}
