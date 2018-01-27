//
//  Observatory.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/27/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import Foundation

//TODO: thread safety
class Observatory {
        
    private static var scopes: [WatchScope] = []
    
    //Collect garbage: scopes whose observables are gone
    private class func gc() {
        scopes = scopes.filter {
            scope in
            return (nil != scope.observable)
        }
    }
    
    private class func scope(for observable: AnyObject) -> WatchScope? {
        return scopes.first {
            theScope in
            return (observable === theScope.observable)
        }
     }
    
    class func watch(_ observable: AnyObject, for watcher: Observer) {
        gc()
        var scope = self.scope(for:observable)
        if (nil == scope) {
            scope = WatchScope(observable)
            scopes.append(scope!)
        }
        
        scope!.add(watcher: watcher)
    }
    
    class func unwatch(_ observable: AnyObject, for watcher: Observer) {
        gc()
        let scope = self.scope(for:observable)
        guard nil != scope else {
            return
        }
        
        scope!.remove(watcher: watcher)
        if (scope!.empty) {
            scopes = scopes.filter {
                theScope in
                return (theScope !== scope)
            }
        }
    }
    
    class func didChange(_ observable: AnyObject) {
        self.scope(for:observable)?.notify()
    }
}
