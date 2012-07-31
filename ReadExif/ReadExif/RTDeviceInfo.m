//
//  RTDeviceInfo.m
//  AiFang
//
//  Created by zheng yan on 12-4-11.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTDeviceInfo.h"
#import "RTNetwork.h"

@implementation RTDeviceInfo


+ (NSString *) hostname
{
    char baseHostName[256]; // Thanks, Gunnar Larisch
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s", baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}


+ (NSString *) localIPAddress
{
    return @"";
}

+ (NSString *)networkStatus {
    return [[RTRequestProxy sharedInstance] getNetworkStatus];
}

+ (NSString *)deviceToken
{
    return @"";
}


+ (NSString *)channelId
{
    return @"A01";
}

+ (NSString *)uniqueIdentifier {
    UIDevice *device = [UIDevice currentDevice];
    return [device uniqueIdentifier];
}

+ (NSString *)iosVersion {
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];    
}

+ (NSString *)umengAPIKey {
#ifdef DEBUG
    return @"4efe7251527015526600001c";//内测
#endif

    return @"4efe7251527015526600001c";//正式环境
}


+ (NSString *)appVersion {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (!appVersion || [appVersion length] == 0)
        appVersion = @"0.0";
    return appVersion;
}

@end
