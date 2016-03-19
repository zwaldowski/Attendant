//
//  Associated.swift
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import ObjectiveC.runtime

public enum AssociationPolicy {
    
    case Unowned
    case Strong(atomic: Bool)
    case Copying(atomic: Bool)
    
    static var Function: AssociationPolicy {
        return .Copying(atomic: false)
    }
    
    private var intValue: Int {
        switch self {
        case .Strong(false):  return objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .Strong(true):   return objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        case .Copying(false): return objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
        case .Copying(true):  return objc_AssociationPolicy.OBJC_ASSOCIATION_COPY
        default:              return objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN
        }
    }
    
    var runtimeValue: objc_AssociationPolicy {
        return objc_AssociationPolicy(intValue)
    }
    
}

extension AssociationPolicy: Hashable {
    
    public var hashValue: Int {
        return intValue
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
