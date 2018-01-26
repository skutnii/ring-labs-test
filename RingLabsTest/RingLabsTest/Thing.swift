//
//  Thing.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/26/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

//An abstract Reddit entity
class Thing {
    typealias Raw = [String: Any]
    let kind: String
    
    init(kind: String) {
        self.kind = kind
    }
    
    func update(with data: Raw) {
        
    }
    
    static let KIND = "kind"
    static let DATA = "data"
    
    class func parse<T: Thing>(array: [Raw]) -> [T] {
        return array.map {
            raw in return T(raw: raw)
        }
    }
    
    required init(raw: Raw) {
        let aKind = (raw[Thing.KIND] as? String) ?? "Thing"
        self.kind = aKind
        
        let data = raw[Thing.DATA] as? Thing.Raw
        guard nil != data else {
            return
        }
        
        self.update(with: data!)
    }
}
