//
//  AssociatedObjectView.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

public struct AssociatedObjectView {
    
    private let object: AnyObject
    
    private init(_ object: AnyObject) {
        self.object = object
    }
    
    private func get<V>(key: AssociationKey<V>, _ map: AnyObject -> V) -> V? {
        if let v: AnyObject = objc_getAssociatedObject(object, key.pointerValue) {
            return map(v)
        }
        return nil
    }
    
    public func value<V: AnyObject>(forKey key: AssociationKey<V>) -> V? {
        return get(key, unsafeDowncast)
    }
    
    public func value<V: _ObjectiveCBridgeable>(forKey key: AssociationKey<V>) -> V? {
        return get(key) { $0 as! V }
    }
    
    private func set<V>(object newValue: AnyObject?, forKey key: AssociationKey<V>) {
        objc_setAssociatedObject(object, key.pointerValue, newValue, key.policy.runtimeValue)
    }
    
    public func set<V: AnyObject>(value newValue: V?, forKey key: AssociationKey<V>) {
        set(object: newValue, forKey: key)
    }
    
    public func set<V: _ObjectiveCBridgeable>(value newValue: V?, forKey key: AssociationKey<V>) {
        set(object: newValue as? AnyObject, forKey: key)
    }
    
}

public func associatedObjects(object: AnyObject) -> AssociatedObjectView {
    return AssociatedObjectView(object)
}
