//
//  Promise.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

//Promise API as in JS
class Promise {
    typealias Handler = (Any?) throws -> Any?
    
    enum State {
        case pending
        case resolved
        case rejected
    }
    
    private var _state : State = .pending
    
    var state : State {
        get {
            return _state
        }
    }
    
    private var _handle: [Promise.Handler] = []
    private var _rescue: [Promise.Handler] = []
    
    private func doResolve(_ result: Any?) -> Any? {
        do {
            var _result = result
            while (_handle.count > 0) {
                let handler = _handle.remove(at: 0)
                _result = try handler(_result)
                
                let deferred = _result as? Promise
                if (nil != deferred) {
                    return deferred!.then {
                        res in
                        self.doResolve(res)
                    }
                }
            }
            
            return _result
        } catch {
            return doReject(error)
        }
    }
    
    private func doReject(_ err: Any?) -> Any? {
        var _error = err
        while (_rescue.count > 0) {
            let handler = _rescue.remove(at: 0)
            _error = try? handler(_error)
        }

        _state = .rejected
        return _error
    }
    
    private var _mainClosed = false
    
    func then(_ handler: @escaping Promise.Handler) -> Promise {
        guard  .pending == _state else {
            return self
        }
        
        guard !_mainClosed else {
            return rescue(handler)
        }
        
        _handle.append(handler)
        
        return self
    }
    
    func rescue(_ handler: @escaping Promise.Handler) -> Promise {
        guard .pending == _state else {
            return self
        }
        
        _mainClosed = true
        _rescue.append(handler)
        
        return self
    }
    
    private init() {
        
    }
 
    typealias Resolver = (Any?) -> ()

    var resolve: Resolver {
        get {
            return {
                res in
                _ = self.doResolve(res)
            }
        }
    }
    
    var reject: Resolver {
        get {
            return {
                res in
                _ = self.doReject(res)
            }
        }
    }
    
    init(_ block: @escaping (@escaping Resolver, @escaping Resolver) ->()) {
        DispatchQueue.main.async {
            block(self.resolve, self.reject)
        }
    }
    
    class func resolve(_ res: Any?) -> Promise {
        return Promise {
            resolve, reject in
            resolve(res)
        }
    }
    
    class func reject(_ res: Any?) -> Promise {
        return Promise {
            resolve, reject in
            resolve(res)
        }
    }
}
