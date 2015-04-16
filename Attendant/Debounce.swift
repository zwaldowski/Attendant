//
//  Debounce.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import AttendantPrivate

public struct ActionToken {
    
    private let storage: COpaquePointer
    private init(_ token: COpaquePointer) {
        self.storage = token
    }
}

public func perform<T: AnyObject>(obj: T, delay: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), function: T -> ()) -> ActionToken {
    return ActionToken(dbo_performAction(obj, delay, queue, {
        function(unsafeDowncast($0))
    }))
}

public func perform(clazz: AnyClass, delay: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), function: () -> ()) -> ActionToken {
    return ActionToken(dbo_classPerformAction(clazz, delay, queue, function))
}

public func debounce<T: AnyObject>(obj: T, key: AssociationKey<T -> ()>, delay: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), function: T -> ()) {
    dbo_debounceAction(obj, key.pointerValue, delay, queue) {
        function(unsafeDowncast($0))
    }
}

public func debounce(clazz: AnyClass, key: AssociationKey<() -> ()>, delay: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), function: () -> ()) {
    dbo_classDebounceAction(clazz, key.pointerValue, delay, queue, function)
}

public func willPerform(obj: AnyObject, actionWithToken token: ActionToken) -> Bool {
    return dbo_willPerformAction(obj, token.storage)
}

public func willPerform<T: AnyObject>(obj: T, actionForKey key: AssociationKey<T -> ()>) -> Bool {
    return dbo_willPerformActionForKey(obj, key.pointerValue)
}

public func willPerform(clazz: AnyClass, actionWithToken token: ActionToken) -> Bool {
    return dbo_willPerformAction(clazz, token.storage)
}

public func willPerform(clazz: AnyClass, actionForKey key: AssociationKey<() -> ()>) -> Bool {
    return dbo_willPerformActionForKey(clazz, key.pointerValue)
}

public func cancel(obj: AnyObject, actionWithToken token: ActionToken) {
    dbo_cancelAction(obj, token.storage)
}

public func cancel<T: AnyObject>(obj: T, actionForKey key: AssociationKey<T -> ()>) {
    dbo_cancelActionWithKey(obj, key.pointerValue)
}

public func cancel(clazz: AnyClass, actionWithToken token: ActionToken) {
    dbo_cancelAction(clazz, token.storage)
}

public func cancel(clazz: AnyClass, actionForKey key: AssociationKey<() -> ()>) {
    dbo_cancelActionWithKey(clazz, key.pointerValue)
}
