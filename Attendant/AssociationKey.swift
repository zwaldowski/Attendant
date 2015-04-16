//
//  AssociationKey.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import ObjectiveC.runtime

private func newUniquePtr() -> UnsafePointer<Void> {
    return UnsafePointer(UnsafeMutablePointer<Void>.alloc(1))
}

private extension StaticString {
    
    var unsafePointerValue: UnsafePointer<Void> {
        precondition(hasPointerRepresentation, "Static string key must have backing representation")
        return UnsafePointer(utf8Start)
    }
    
}

public struct AssociationKey<T> {
    
    let pointerValue: UnsafePointer<Void>
    public let policy: AssociationPolicy
    
    private init(pointer: UnsafePointer<Void>, policy: AssociationPolicy) {
        self.pointerValue = pointer
        self.policy = policy
    }
    
}

public func association<T: AnyObject>(atomic: Bool = false) -> AssociationKey<T> {
    return AssociationKey(pointer: newUniquePtr(), policy: .Strong(atomic: atomic))
}

public func association<T: NSCopying>(copyAtomic atomic: Bool = false) -> AssociationKey<T> {
    return AssociationKey(pointer: newUniquePtr(), policy: .Copying(atomic: atomic))
}

public func association<T: _ObjectiveCBridgeable>(copyAtomic atomic: Bool = false) -> AssociationKey<T> {
    return AssociationKey(pointer: newUniquePtr(), policy: .Copying(atomic: atomic))
}

public func association<T>() -> AssociationKey<Unmanaged<T>> {
    return AssociationKey(pointer: newUniquePtr(), policy: .Unowned)
}

private func functionAssociation<T>(var ptr: UnsafePointer<Void>) -> AssociationKey<T -> ()> {
    if ptr == nil {
        ptr = newUniquePtr()
    }
    return AssociationKey(pointer: ptr, policy: .Function)
}

public func eventAssocation(ptr: UnsafePointer<Void>) -> AssociationKey<() -> ()> {
    return functionAssociation(ptr)
}

public func eventAssocation(name: StaticString = __FUNCTION__) -> AssociationKey<() -> ()> {
    precondition(name.hasPointerRepresentation, "Static string key must have backing representation")
    return functionAssociation(UnsafePointer(name.utf8Start))
}

public func eventAssocation<T>(ptr: UnsafePointer<Void>) -> AssociationKey<T -> ()> {
    return functionAssociation(ptr)
}

public func eventAssocation<T>(name: StaticString = __FUNCTION__) -> AssociationKey<T -> ()> {
    precondition(name.hasPointerRepresentation, "Static string key must have backing representation")
    return functionAssociation(UnsafePointer(name.utf8Start))
}
