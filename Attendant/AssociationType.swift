//
//  AssociationType.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright © 2015-2016 Big Nerd Ranch. All rights reserved.
//

private let class_setAssociatedObject: @convention(c) (NSObject.Type, UnsafePointer<Void>, AnyObject!, objc_AssociationPolicy) -> Void = objc_setAssociatedObject
private let class_getAssociatedObject: @convention(c) (NSObject.Type, UnsafePointer<Void>) -> AnyObject? = objc_getAssociatedObject

public protocol AssociationType: CustomDebugStringConvertible {

    typealias Value

    var identifier: UInt { get }
    var policy: AssociationPolicy { get }

}

extension AssociationType {

    public var debugDescription: String {
        return "\(UnsafePointer<Void>(bitPattern: identifier)) for \(policy)"
    }

}

private extension AssociationType {

    func getObjectFrom<Return>(object target: AnyObject, @noescape transform body: AnyObject throws -> Return) rethrows -> Return? {
        guard let object = objc_getAssociatedObject(target, .init(bitPattern: identifier)) else {
            return nil
        }
        return try body(object)
    }

    func getObjectFrom<Return>(type target: NSObject.Type, @noescape transform body: AnyObject throws -> Return) rethrows -> Return? {
        guard let object = class_getAssociatedObject(target, .init(bitPattern: identifier)) else {
            return nil
        }
        return try body(object)
    }

    func setObject(object: AnyObject?, onObject target: AnyObject) {
        objc_setAssociatedObject(target, .init(bitPattern: identifier), object, policy.runtimeValue)
    }

    func setObject(object: AnyObject?, onType target: NSObject.Type) {
        class_setAssociatedObject(target, .init(bitPattern: identifier), object, policy.runtimeValue)
    }

}

extension AssociationType where Value: AnyObject {

    public subscript(target: AnyObject) -> Value? {
        get {
            return getObjectFrom(object: target, transform: unsafeDowncast)
        }
        nonmutating set {
            setObject(newValue, onObject: target)
        }
    }

    public subscript(target: NSObject.Type) -> Value? {
        get {
            return getObjectFrom(type: target, transform: unsafeDowncast)
        }
        nonmutating set {
            setObject(newValue, onType: target)
        }
    }
    
}

extension AssociationType where Value: _ObjectiveCBridgeable {

    public subscript(target: AnyObject) -> Value? {
        get {
            return getObjectFrom(object: target) { $0 as! Value }
        }
        nonmutating set {
            setObject(newValue as? AnyObject, onObject: target)
        }
    }

    public subscript(target: NSObject.Type) -> Value? {
        get {
            return getObjectFrom(type: target) { $0 as! Value }
        }
        nonmutating set {
            setObject(newValue as? AnyObject, onType: target)
        }
    }

}
