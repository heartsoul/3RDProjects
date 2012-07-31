//
//  CrashLogUtil.h
//  Anjuke
//
//  Created by xu chao on 12-1-13.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashLogUtil : NSObject
+ (void)writeCrashLog;//写异常日志
+ (void)logAppStart;
+ (void)logAppEnd;
+ (NSString *)myNetworkStatus;
+ (void)saveCrash:(NSException *)exception;
+ (BOOL)hasCrashHappen;
+ (NSArray *)getCrashLog;
+ (void)delCrashLog;
@end
