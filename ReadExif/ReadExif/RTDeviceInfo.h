//
//  RTDeviceInfo.h
//  AiFang
//
//  Created by zheng yan on 12-4-11.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTDeviceInfo : NSObject

+ (NSString *)channelId;
+ (NSString *)deviceToken;
+ (NSString *)networkStatus;
+ (NSString *)localIPAddress;
+ (NSString *)uniqueIdentifier;
+ (NSString *)iosVersion;
+ (NSString *)umengAPIKey;
+ (NSString *)appVersion;

@end
