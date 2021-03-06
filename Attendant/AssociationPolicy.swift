//
//  AssociationPolicy.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright © 2015-2016 Big Nerd Ranch. All rights reserved.
//

import ObjectiveC.runtime

public enum AssociationPolicy {
    
    case Unowned
    case Strong(atomic: Bool)
    case Copying(atomic: Bool)

    var runtimeValue: objc_AssociationPolicy {
        switch self {
        case .Strong(false):  return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .Strong(true):   return .OBJC_ASSOCIATION_RETAIN
        case .Copying(false): return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .Copying(true):  return .OBJC_ASSOCIATION_COPY
        default:              return .OBJC_ASSOCIATION_ASSIGN
        }
    }
    
}

extension AssociationPolicy: Hashable {
    
    public var hashValue: Int {
        return runtimeValue.hashValue
    }
    
}

public func ==(lhs: AssociationPolicy, rhs: AssociationPolicy) -> Bool {
    switch (lhs, rhs) {
    case (.Unowned, .Unowned):
        return true
    case (.Strong(let latomic), .Strong(let ratomic)):
        return latomic == ratomic
    case (.Copying(let latomic), .Copying(let ratomic)):
        return latomic == ratomic
    default:
        return false
    }
}
