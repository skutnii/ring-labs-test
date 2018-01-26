//
//  HTTP.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/26/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

class HTTP {
    
    class func fetch(_ link: String) -> Promise {
        return Promise {
            resolve, reject in
            let url = URL(string: link)
            guard nil != url else {
                reject("Invalid URL \(link)")
                return
            }
            
            URLSession.shared.dataTask(with: url!) {
                data, response, error in
                guard nil == error else {
                    reject("Connection error")
                    return
                }
                
                let code = (response as? HTTPURLResponse)?.statusCode ?? 400
                guard code <= 400 else {
                    reject("HTTP error \(code)")
                    return
                }
                
                guard nil != data else {
                    reject("No data")
                    return
                }
                
                resolve(data)
            } .resume()
        }
    }
    
    class func fetchJSON(_ link: String) -> Promise {
        return fetch(link).then {
            result in
            let data = result as! Data
            do {
                let content = try JSONSerialization.jsonObject(with: data, options: [])
                return content
            } catch {
                return Promise.reject("Parse error")
            }
        }
    }
    
}
