//
//  RTLogger.h
//  AiFang
//
//  Created by zheng yan on 12-4-11.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MobClick.h"

@protocol RTLoggerCacheDelegate <NSObject>
- (void)addLog:(NSString *)logString;
- (NSArray *)fetchLogs;
- (void)removeLogs;
@end

@protocol RTLoggerLocationDelegate <NSObject>
//- (NSString *)currentCityID;
- (CLLocation *)userLocation;
@end

@interface RTLogger : NSObject<MobClickDelegate>

@property (nonatomic, retain) NSArray *appLogs;
@property (nonatomic, copy) NSString *logAppName;
@property (nonatomic, assign) id<RTLoggerCacheDelegate> cacheDelegate;
@property (nonatomic, assign) id<RTLoggerLocationDelegate> infoDelegate;

+ (id)sharedInstance;
- (id)init;

- (void)logWithEventLabel:(NSString *)eventLabel PageLabel:(NSString *)pageLabel note:(NSDictionary *)note;

// app become active, enter background
- (void)logAppBecomeActive;
- (void)logAppEnterBackground;

@end
