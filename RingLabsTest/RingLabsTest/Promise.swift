//
//  Promise.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

//Promise API as in JS
protocol Thenable {
    typealias Handler = (Any?) throws -> Any?
    func then(_ block: @escaping Handler) -> Thenable
}

fileprivate class Sequence : Thenable {
    var _body: Handler
    var _next: Sequence?
    
    init(_ body: @escaping Handler) {
        _body = body
    }
    
    convenience init() {
        self.init {
            res in return res
        }
    }
    
    func then(_ block: @escaping Handler) -> Thenable {
        return self.append(Sequence(block))
    }
    
    func append(_ sequence: Sequence?) -> Sequence {
        guard nil == _next else {
            return _next!.append(sequence)
        }
        
        _next = sequence
        return self
    }
}

class Promise {
    
    private var _main : Sequence
    private var _rescue: Sequence?
    
    typealias Handler = Thenable.Handler
    
    private init(main: Sequence, rescue:Sequence?) {
        _main = main
        _rescue = rescue
    }
    
    convenience init() {
        self.init(main: Sequence({ res in return res }), rescue: nil)
    }
    
    private func chain(next: Sequence?, resc: Sequence?) -> Promise {
        _ = _main.append(next)
        
        if (nil == _rescue)  {
            _rescue = resc
        } else {
            _ = _rescue!.append(resc)
        }
        
        return self
    }
    
    private func next(value: Any?) -> Any? {
        do {
            
            let result = try _main._body(value)
            guard nil == result as? Promise else {
                return (result as! Promise).chain(next: _main._next, resc: _rescue)
            }
            
            let next = _main._next
            guard nil != next else {
                return result
            }
            
            return Promise(main:next!, rescue:_rescue).next(value: result)
        } catch {
            reject(error)
            return nil
        }
    }
    
    func resolve(_ value: Any?) {
        _ = next(value: value)
    }
    
    func reject(_ error: Any?) {
        var err = error
        var rescue: Sequence? = _rescue
        while (nil != rescue) {
            err = (try? rescue!._body(err)) ?? nil
            rescue = rescue!._next
        }
    }
    
    func then(_ block: @escaping Handler) -> Promise {
        return self.chain(next: Sequence(block), resc: nil)
    }
    
    func rescue(_ block: @escaping Handler) -> Thenable {
        _ = self.chain(next: nil, resc: Sequence(block))
        return _rescue!
    }
    
    typealias Resolver = (Any?) -> ()
    convenience init(_ block: @escaping (@escaping Resolver, @escaping Resolver) ->()) {
        self.init()
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
            reject(res)
        }
    }
    
    class func all(_ promises: [Promise]) -> Promise {
        guard promises.count > 0 else {
            return Promise.resolve(true)
        }
        
        class Semaphore {
            let max : Int

            var resolved : Int = 0
            var rejected: Bool = false
            
            var results = [Any]()
            
            init(_ count: Int) {
                max = count
            }
        }
        
        let semaphore = Semaphore(promises.count)
        let combo = Promise()
        
        promises.forEach {
            promise in
            _ = promise.then {
                result in
                if (!semaphore.rejected) {
                    if (nil != result) {
                        semaphore.results.append(result!)
                    }
                    
                    semaphore.resolved += 1
                    if (semaphore.resolved == semaphore.max) {
                        combo.resolve(semaphore.results)
                    }
                }
                
                return result
            } .rescue {
                error in
                if (!semaphore.rejected) {
                    semaphore.rejected = true
                    combo.reject(error)
                }
                
                return error
            }
        }
        
        return combo
    }
    
    class func race(_ promises: [Promise]) -> Promise {
        guard promises.count > 0 else {
            return Promise.resolve(true)
        }
        
        class Semaphore {
            var resolved = false
            var rejected: Int = 0
            let max: Int
            
            var errors = [Any]()
            init(_ count: Int) {
                max = count
            }
        }
        
        let semaphore = Semaphore(promises.count)
        let combo = Promise()
        
        promises.forEach {
            promise in
            _ = promise.then {
                result in
                if (!semaphore.resolved) {
                    semaphore.resolved = true
                    combo.resolve(result)
                }
                
                return result
            } .rescue {
                error in
                if (!semaphore.resolved) {
                    if (nil != error) {
                        semaphore.errors.append(error!)
                    }
                    
                    semaphore.rejected += 1
                    if (semaphore.max == semaphore.rejected) {
                        combo.reject(semaphore.errors)
                    }
                }
                
                return error
            }
        }
        
        return combo
    }
}
