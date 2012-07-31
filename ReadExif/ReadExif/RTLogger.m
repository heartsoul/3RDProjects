//
//  RTLogger.m
//  AiFang
//
//  Created by zheng yan on 12-4-11.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTLogger.h"
#import "SBJSON.h"
#import "RTNetwork.h"
#import "RTDeviceInfo.h"

#define SEND_LOG_INTERVAL 60

@interface RTLogger()
- (NSDictionary *)composeRTLogWithPage:(NSString *)pageLabel event:(NSString *)eventLabel note:(NSDictionary *)note;
@end

@implementation RTLogger
@synthesize appLogs = _appLogs;
@synthesize logAppName = _logAppName;
@synthesize cacheDelegate = _cacheDelegate;
@synthesize infoDelegate = _infoDelegate;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTLogger *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTLogger alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:SEND_LOG_INTERVAL target:self selector:@selector(sendLog:) userInfo:NO repeats:YES];
        [MobClick setDelegate:self reportPolicy:BATCH];
    }
    
    return self;
}

#pragma mark - Methods
- (void)logWithEventLabel:(NSString *)eventLabel PageLabel:(NSString *)pageLabel note:(NSDictionary *)note
{
    //AppLog
    NSDictionary *rtLog = [self composeRTLogWithPage:pageLabel event:eventLabel note:note];
    
#ifdef DEBUG
    // send log realtime
    NSArray *logArray = [NSArray arrayWithObject:rtLog];
    NSMutableDictionary *logDict = [[[NSMutableDictionary alloc] init] autorelease];
    [self addParamsWithData:logArray inDict:logDict];
    NSDictionary *logJsonDict = [NSDictionary dictionaryWithObjectsAndKeys:[logDict JSONRepresentation], @"log", nil];
    DLog(@"realtime send log: %@", logJsonDict);
    
    [[RTRequestProxy sharedInstance] asyncPostWithServiceID:RTAnjukeServiceID methodName:@"admin.writeAppLog" params:logJsonDict target:self action:@selector(onSentLogRealtime:)];    
#else
    [self.cacheDelegate addLog:[rtLog JSONRepresentation]];
#endif
    
    //UMENG
    NSDictionary *log = [NSDictionary dictionaryWithObjectsAndKeys:eventLabel, @"event", pageLabel, @"label", note,@"note", nil];
    [self performSelectorInBackground:@selector(MobClickEvent:) withObject:log];
}

- (void)logAppBecomeActive {
    [MobClick appLaunched];
}

- (void)logAppEnterBackground {
    [MobClick appTerminated];
}

#pragma mark - handle log
// schedule event
- (void)sendLog:(id)sender {
    // 1. async send only when appLogs's count > 0
    if ([self.appLogs count] > 0) {
        NSDictionary *logDict = [self combineAppLogs:self.appLogs];
        NSDictionary *logJsonDict = [NSDictionary dictionaryWithObjectsAndKeys:[logDict JSONRepresentation], @"log", nil];
        
        NSLog(@"batch send log: %@", logJsonDict);
        [[RTRequestProxy sharedInstance] asyncPostWithServiceID:RTAnjukeServiceID methodName:@"admin.writeAppLog" params:logJsonDict target:self action:@selector(onSentLog:)];
    } else
        self.appLogs = [self.cacheDelegate fetchLogs];
}

- (void)onSentLog:(RTNetworkResponse *)response {
    if ([response status] != RTNetworkResponseStatusSuccess) {
        DLog(@"RTNetwork error:%@", [response content]);
        return;
    }
    
    //    DLog(@"%@", [response content]);
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        // remove sending logs 
        [self.cacheDelegate removeLogs];
        self.appLogs = [self.cacheDelegate fetchLogs];
    }
}

- (void)onSentLogRealtime:(RTNetworkResponse *)response {
    if ([response status] != RTNetworkResponseStatusSuccess) {
        DLog(@"RTNetwork error:%@", [response content]);
        return;
    }
    
    //    DLog(@"%@", [response content]);
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        // remove sending logs 
//        DLog(@"send applog OK");
    }
}

- (void)MobClickEvent:(NSDictionary *)log {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [log retain];
    NSMutableString *label = [NSMutableString stringWithString:[log objectForKey:@"label"]];
    if ([[log objectForKey:@"note"] objectForKey:@"ext"]!=nil) {
        [label appendFormat:@"_%@",[[log objectForKey:@"note"] objectForKey:@"ext"]];
    }
    [MobClick event:[log objectForKey:@"event"] label:label];
    
    [log release];
    [pool release];
}


#pragma mark - build log
// for send to webservice
- (NSDictionary *)combineAppLogs:(NSArray *)logs {
    NSMutableDictionary *logDict = [[[NSMutableDictionary alloc] init] autorelease];

    [self addParamsWithData:logs inDict:logDict];
    return logDict;
}

- (void) addParamsWithData:(id)data inDict:(NSMutableDictionary *)logDict {    
    CLLocationCoordinate2D coordinate = [[self.infoDelegate userLocation] coordinate];
    
    [logDict setValue:self.logAppName forKey:@"app"];
    [logDict setValue:data forKey:@"data"];
    [logDict setValue:[NSString stringWithFormat:@"%f", coordinate.latitude] forKey:@"lat"];
    [logDict setValue:[NSString stringWithFormat:@"%f", coordinate.longitude] forKey:@"lnt"];
    [logDict setValue:[RTDeviceInfo channelId] forKey:@"prom_id"];
    [logDict setValue:[RTDeviceInfo deviceToken] forKey:@"deviceToken"];
    [logDict setValue:[RTDeviceInfo uniqueIdentifier] forKey:@"ud"];
}

// for store in coredata
- (NSDictionary *)composeRTLogWithPage:(NSString *)pageLabel event:(NSString *)eventLabel note:(NSDictionary *)note {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    NSString *appVersion = [RTDeviceInfo appVersion];

    NSMutableDictionary *log = [[[NSMutableDictionary alloc] init] autorelease];
    [log setObject:@"event" forKey:@"type"];
    [log setObject:@"ios" forKey:@"os"];
    [log setObject:now forKey:@"timestamp"];
    if (pageLabel)
        [log setObject:pageLabel forKey:@"page"];
    if (eventLabel)
        [log setObject:eventLabel forKey:@"name"];
    if (note)
        [log setObject:note forKey:@"note"];
    if ([RTDeviceInfo localIPAddress])
        [log setObject:[RTDeviceInfo localIPAddress] forKey:@"ip"];
    if ([RTDeviceInfo networkStatus])
        [log setObject:[RTDeviceInfo networkStatus] forKey:@"network"];
    if ([RTDeviceInfo iosVersion])
        [log setObject:[RTDeviceInfo iosVersion] forKey:@"dver"];
    if (appVersion)
        [log setObject:appVersion forKey:@"ver"];
    
    return log;
}

#pragma mark - umeng delegate
- (NSString *)appKey {
    return [RTDeviceInfo umengAPIKey];
}

- (NSString *)channelId {
    return [RTDeviceInfo channelId];
}

@end
