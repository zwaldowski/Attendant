//
//  ObjectAssociation.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright © 2015-2016 Big Nerd Ranch. All rights reserved.
//

import ObjectiveC.runtime

private func makeUniquePointer() -> UnsafePointer<Void> {
    return UnsafePointer(UnsafeMutablePointer<Void>.alloc(0))
}

public protocol ValueAssociation: AssociationType {

    var atomic: Bool { get }

    init(identifier: UInt, assignedAtomically atomic: Bool)

}

extension ValueAssociation {

    public var policy: AssociationPolicy {
        return .Strong(atomic: atomic)
    }

    public init(pointer: UnsafePointer<Void> = makeUniquePointer(), assignedAtomically atomic: Bool = false) {
        self.init(identifier: unsafeBitCast(pointer, UInt.self), assignedAtomically: atomic)
    }

}

public struct ObjectAssociation<Object: AnyObject>: ValueAssociation {

    public typealias Value = Object

    public let identifier: UInt
    public let atomic: Bool

    public init(identifier: UInt, assignedAtomically atomic: Bool) {
        self.identifier = identifier
        self.atomic = atomic
    }

}

public struct CopiedObjectAssociation<Object: NSCopying>: ValueAssociation {

    public typealias Value = Object

    public let identifier: UInt
    public let atomic: Bool

    public init(identifier: UInt, assignedAtomically atomic: Bool) {
        self.identifier = identifier
        self.atomic = atomic
    }

    public var policy: AssociationPolicy {
        return .Copying(atomic: atomic)
    }
    
}

public struct BridgedValueAssociation<BridgedValue: _ObjectiveCBridgeable>: ValueAssociation {

    public typealias Value = BridgedValue

    public let identifier: UInt
    public let atomic: Bool

    public init(identifier: UInt, assignedAtomically atomic: Bool) {
        self.identifier = identifier
        self.atomic = atomic
    }

    public var policy: AssociationPolicy {
        return .Copying(atomic: atomic)
    }
    
}

public struct UnownedObjectAssociation<Object: AnyObject>: ValueAssociation {

    public typealias Value = Unmanaged<Object>

    public let identifier: UInt
    public let atomic: Bool = false

    public init(identifier: UInt) {
        self.identifier = identifier
    }

    public var policy: AssociationPolicy {
        return .Unowned
    }

    public init(identifier: UInt, assignedAtomically _: Bool) {
        self.identifier = identifier
    }
    
}

public enum Association {

    public static func forObject<Value: AnyObject>(ofType _: Value.Type = Value.self, identifier pointer: UnsafePointer<Void> = makeUniquePointer(), assignedAtomically atomic: Bool = false) -> ObjectAssociation<Value> {
        return .init(pointer: pointer, assignedAtomically: atomic)
    }

    public static func forObject<Value: NSCopying>(ofType _: Value.Type = Value.self, identifier pointer: UnsafePointer<Void> = makeUniquePointer(), assignedAtomically atomic: Bool = false) -> CopiedObjectAssociation<Value> {
        return .init(pointer: pointer, assignedAtomically: atomic)
    }

    public static func forValue<Value: _ObjectiveCBridgeable>(ofType _: Value.Type = Value.self, identifier pointer: UnsafePointer<Void> = makeUniquePointer(), assignedAtomically atomic: Bool = false) -> BridgedValueAssociation<Value> {
        return .init(pointer: pointer, assignedAtomically: atomic)
    }

    public static func forUnownedObject<Value: AnyObject>(ofType _: Value.Type = Value.self, identifier pointer: UnsafePointer<Void> = makeUniquePointer()) -> UnownedObjectAssociation<Value> {
        return .init(pointer: pointer, assignedAtomically: false)
    }

}
