//
//  RTLogCacheManager.h
//  AnjukeBroker
//
//  Created by zheng yan on 12-5-31.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTLogger.h"

@interface RTLogCacheManager : NSObject <RTLoggerCacheDelegate>

@property (nonatomic, retain) NSArray *cachedLogs;

+ (id) sharedInstance;
- (id) init;

@end
