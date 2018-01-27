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

    class Keys {
        static let kind = "kind"
        static let data = "data"
    }
    
    class func parse<T: Thing>(array: [Raw]) -> [T] {
        return array.map {
            raw in return T(raw: raw)
        }
    }
    
    required init(raw: Raw) {
        let aKind = (raw[Keys.kind] as? String) ?? "Thing"
        self.kind = aKind
        
        let data = raw[Keys.data] as? Thing.Raw
        guard nil != data else {
            return
        }
        
        self.update(with: data!)
    }
    
    var data : Raw {
        get {
            return [:]
        }
    }
    
    final var json: Raw {
        get {
            return [
                Keys.kind: self.kind,
                Keys.data: self.data
            ]
        }
    }
}
