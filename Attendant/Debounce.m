//
//  Debounce.m
//  Testytest
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Pyramidia, Inc. All rights reserved.
//

#import "Debounce.h"
@import Foundation;
@import ObjectiveC.runtime;

NS_INLINE DBOActionToken makeDebounceKey(const void *inKey) {
    static const void *_debounceHashKey = &_debounceHashKey;
    return (DBOActionToken)((uintptr_t)inKey ^ (uintptr_t)_debounceHashKey);
}

static void performActionUpon(id obj, const void *key, double delay, dispatch_queue_t q, dispatch_block_t inBlock) {
    dispatch_block_t wrapper = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, inBlock);
    
    id activity = nil;
    if (delay == 0.0) {
        activity = [NSProcessInfo.processInfo beginActivityWithOptions:NSActivityBackground reason:@"Delayed perform with delay 0"];
    }

    dispatch_block_notify(wrapper, q, ^{
        objc_setAssociatedObject(obj, key, nil, OBJC_ASSOCIATION_COPY);
        if (activity != nil) {
            [NSProcessInfo.processInfo endActivity:activity];
        }
    });
    
    objc_setAssociatedObject(obj, key, wrapper, OBJC_ASSOCIATION_COPY);
    
    if (delay > 0.0) {
        dispatch_after(dispatch_time_with_seconds(delay), q, wrapper);
    } else {
        dispatch_async(q, wrapper);
    }
}

DBOActionToken dbo_performAction(id obj, double delay, dispatch_queue_t queue, void(^inBlock)(id)) {
    id block = [^{
        inBlock(obj);
    } copy];
    DBOActionToken key = makeDebounceKey((__bridge void *)block);
    
    performActionUpon(obj, key, delay, queue, block);
    
    return key;
}

DBOActionToken dbo_classPerformAction(Class clazz, double delay, dispatch_queue_t queue, void(^inBlock)(void)) {
    id block = [inBlock copy];
    DBOActionToken key = makeDebounceKey((__bridge void *)block);
    
    performActionUpon(clazz, key, delay, queue, block);
    
    return key;
}

void dbo_debounceAction(id obj, const void *inKey, double delay, dispatch_queue_t queue, void(^block)(id)) {
    const void *key = makeDebounceKey(inKey);
    dbo_cancelAction(obj, key);
    performActionUpon(obj, key, delay, queue, ^{
        block(obj);
    });
}

void dbo_classDebounceAction(Class clazz, const void *inKey, double delay, dispatch_queue_t queue, void(^block)(void)) {
    const void *key = makeDebounceKey(inKey);
    dbo_cancelAction(clazz, key);
    performActionUpon(clazz, key, delay, queue, block);
}

BOOL dbo_willPerformAction(id obj, DBOActionToken token) {
    return objc_getAssociatedObject(obj, token) != nil;
}

BOOL dbo_willPerformActionForKey(id obj, const void *key) {
    return dbo_willPerformAction(obj, makeDebounceKey(key));
}

void dbo_cancelAction(id obj, DBOActionToken token) {
    dispatch_block_t block = objc_getAssociatedObject(obj, token);
    if (block != NULL) {
        dispatch_block_cancel(block);
    }
}

void dbo_cancelActionWithKey(id obj, const void *key) {
    dbo_cancelAction(obj, makeDebounceKey(key));
}
