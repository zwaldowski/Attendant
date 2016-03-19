//
//  Debounce.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright © 2015-2016 Big Nerd Ranch. All rights reserved.
//

import Foundation

private var debounceHashKey = false

private extension StaticString {

    var debounceIdentifier: UInt {
        return withUnsafePointer(&debounceHashKey) {
            if hasPointerRepresentation {
                return unsafeBitCast(utf8Start, UInt.self) ^ unsafeBitCast($0, UInt.self)
            } else {
                return UInt(unicodeScalar.value) ^ unsafeBitCast($0, UInt.self)
            }
        }
    }

}

public protocol FunctionAssociation: AssociationType {

    init(identifier: UInt)
    
}

extension FunctionAssociation {

    public init(key: StaticString = __FUNCTION__) {
        self.init(identifier: key.debounceIdentifier)
    }

    public var policy: AssociationPolicy {
        return AssociationPolicy.Strong(atomic: true)
    }

}

private extension FunctionAssociation {

    private func reset(timer timer: dispatch_source_t, delay: NSTimeInterval) {
        dispatch_source_set_timer(timer, UInt64(delay * Double(NSEC_PER_SEC)), DISPATCH_TIME_FOREVER, NSEC_PER_SEC / 10)
    }

    private func makeTimer(delay delay: NSTimeInterval, upon queue: dispatch_queue_t, handler: dispatch_block_t, cancelHandler: dispatch_block_t) -> dispatch_source_t {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)!
        let wrapped = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            handler()
            dispatch_source_cancel(timer)
        }
        dispatch_source_set_event_handler(timer, wrapped)
        dispatch_source_set_cancel_handler(timer, cancelHandler)
        reset(timer: timer, delay: delay)
        return timer
    }

    private func scheduleTimer(after delay: NSTimeInterval, upon queue: dispatch_queue_t, @noescape getter: () -> dispatch_source_t?, setter: dispatch_source_t? -> Void, body: Void -> Void) {
        if let timer = getter() {
            reset(timer: timer, delay: delay)
            return
        }

        let timer = makeTimer(delay: delay, upon: queue, handler: body, cancelHandler: {
            setter(nil)
        })
        setter(timer)
        dispatch_resume(timer)
    }

    func cancelTimer(@noescape getter: () -> dispatch_source_t?) {
        if let timer = getter() {
            dispatch_source_cancel(timer)
        }
    }

}

public struct EventAssociation<Sender: AnyObject>: FunctionAssociation {

    public typealias Value = dispatch_source_t
    public typealias Body = Sender -> Void

    public let identifier: UInt

    public init(identifier: UInt) {
        self.identifier = identifier
    }

    public var debugDescription: String {
        return "\(UnsafePointer<Void>(bitPattern: identifier)) for (\(Body.self))"
    }

    public func perform(onTarget target: Sender, after delay: NSTimeInterval = 0, upon queue: dispatch_queue_t = dispatch_get_main_queue(), body: Body) {
        scheduleTimer(after: delay, upon: queue, getter: {
            self[target]
        }, setter: {
            self[target] = $0
        }, body: {
            body(target)
        })
    }

    public func willBePerformed(onTarget target: Sender) -> Bool {
        return self[target] != nil
    }

    public func cancel(target target: Sender) {
        cancelTimer {
            self[target]
        }
    }
    
}

public struct TypeAssociation<Sender: NSObject>: FunctionAssociation {

    public typealias Value = dispatch_source_t
    public typealias Body = Sender.Type -> Void

    public let identifier: UInt

    public init(identifier: UInt) {
        self.identifier = identifier
    }

    public var debugDescription: String {
        return "\(UnsafePointer<Void>(bitPattern: identifier)) for (\(Body.self))"
    }

    public func perform(after delay: NSTimeInterval = 0, upon queue: dispatch_queue_t = dispatch_get_main_queue(), body: Sender.Type -> Void) {
        scheduleTimer(after: delay, upon: queue, getter: {
            self[Sender.self]
        }, setter: {
            self[Sender.self] = $0
        }, body: {
            body(Sender.self)
        })
    }

    public var willBePerformed: Bool {
        return self[Sender.self] != nil
    }

    public func cancel() {
        cancelTimer {
            self[Sender.self]
        }
    }

}

extension Association {

    public static func forEvent<Sender>(withKey key: StaticString = __FUNCTION__, withType _: Sender.Type = Sender.self) -> EventAssociation<Sender> {
        return .init(key: key)
    }

    public static func forEvent<Sender, Group: RawRepresentable where Group.RawValue == StaticString>(withKey key: Group, withType _: Sender.Type = Sender.self) -> EventAssociation<Sender> {
        return .init(key: key.rawValue)
    }

    public static func forEvent<Sender>(withKey key: StaticString = __FUNCTION__, uponType _: Sender.Type = Sender.self) -> TypeAssociation<Sender> {
        return .init(key: key)
    }

    public static func forEvent<Sender, Group: RawRepresentable where Group.RawValue == StaticString>(withKey key: Group, uponType _: Sender.Type = Sender.self) -> TypeAssociation<Sender> {
        return .init(key: key.rawValue)
    }

}
