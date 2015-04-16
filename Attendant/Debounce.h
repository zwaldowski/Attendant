//
//  Debounce.h
//  Attendant
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

@import Foundation.NSObjCRuntime;
@import Dispatch;

NS_INLINE dispatch_time_t dispatch_time_with_seconds(double t) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC));
}

NS_ASSUME_NONNULL_BEGIN

typedef const struct _opaque_ptr *DBOActionToken;

extern DBOActionToken dbo_performAction(id obj, double delay, dispatch_queue_t queue, void(^block)(id));
extern DBOActionToken dbo_classPerformAction(Class clazz, double delay, dispatch_queue_t queue, void(^block)(void));

extern void dbo_debounceAction(id obj, const void *key, double delay, dispatch_queue_t queue, void(^block)(id));
extern void dbo_classDebounceAction(Class clazz, const void *key, double delay, dispatch_queue_t queue, void(^block)(void));

extern BOOL dbo_willPerformAction(id obj, DBOActionToken token);
extern BOOL dbo_willPerformActionForKey(id obj, const void *key);
extern void dbo_cancelAction(id obj, DBOActionToken token);
extern void dbo_cancelActionWithKey(id obj, const void *key);

NS_ASSUME_NONNULL_END
