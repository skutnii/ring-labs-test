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
    static let SCHEMA = "https://example.com"
    static let API = "https://reddit.com"
    
    enum ApiError: Error {
        case NonMatchingState
    }
        
    class func authorize(_ presenter: OAuthViewController) -> Promise {
        let uid = UUID().description
        let authURL = URL("https://www.reddit.com/api/v1/authorize", [
            "client_id": Reddit.KEY,
            "response_type": "token",
            "state": uid,
            "redirect_uri": Reddit.SCHEMA,
            "duration": "temporary",
            "scope": "read"
        ])
        
        return Promise { resolve, reject in
            presenter.onCancel {
                reject("Cancelled by user")
            }
            
            presenter.onComplete { url in
                let parts = url?.absoluteString.split(separator: "#")
                guard (nil != parts) && (parts!.count > 1) else {
                    reject("No query result")
                    return
                }
                
                let query = parts![1]
                do {
                    try query.split(separator: "&").forEach { fragment in
                        let parts = fragment.split(separator: "=")
                        if (parts.count > 1) {
                            if ("access_token" == parts[0]) {
                                Reddit.token = String(parts[1])
                            }
                            
                            if (("state" == parts[0]) && (uid != parts[1])) {
                                throw ApiError.NonMatchingState
                            }
                        }
                    }
                } catch ApiError.NonMatchingState {
                    reject("State values do not match in request and response")
                } catch {
                    reject(error)
                }
                
                if (nil == Reddit.token) {
                    reject("No token")
                }
                
                resolve(Reddit.token)
            }
            
            presenter.load(authURL)
        }
    }
    
    class func get(_ path: String) -> Promise {
        let link = API + path
        let url = URL(string: link)
        guard nil != url else {
            return Promise.reject("Invalid URL with path \(path)")
        }
        
        var request = URLRequest(url: url!)
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
        return Promise {
            resolve, reject in
            URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                guard  nil == error else {
                    reject("Connection error")
                    return
                }
                
                let code = (response as? HTTPURLResponse)?.statusCode ?? 400
                guard code <= 400 else {
                    reject("HTTP error \(code) for url \(url!)")
                    return
                }
                
                guard nil != data else {
                    reject("No data")
                    return
                }
                
                do {
                    let value = try JSONSerialization.jsonObject(with: data!)
                    resolve(value)
                } catch {
                    reject("Parse error")
                }
            }).resume()
        }
    }
}
