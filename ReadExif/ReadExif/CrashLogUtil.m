//
//  CrashLogUtil.m
//  Anjuke
//
//  Created by xu chao on 12-1-13.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "CrashLogUtil.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#import "RTNetwork/RTNetwork.h"

#import "AppDelegate.h"
#import "RTDeviceInfo.h"
#import "SBJSON.h"


@implementation CrashLogUtil

+ (NSString *)pathStartEnd{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"appStartEnd.plist"];
}

+ (NSString *)pathCrashReport {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crash.plist"];
}

+ (void)logAppStart{
    //应用启动记录
    NSData *now = [NSDate date];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:now,@"startTime",
                         now,@"endTime",nil];
    [dic writeToFile:[CrashLogUtil pathStartEnd] atomically:YES];
}

+ (void)logAppEnd{
    //应用结束记录
    if ([[NSFileManager defaultManager] fileExistsAtPath:[CrashLogUtil pathStartEnd]]) {
        NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithContentsOfFile:[CrashLogUtil pathStartEnd]];
        [mutDic setValue:[NSDate date] forKey:@"endTime"];
        [mutDic writeToFile:[CrashLogUtil pathStartEnd] atomically:YES];
    }
}

+ (void) handleCrashReport:(NSMutableDictionary *)dicLog {

    NSArray *crashReports = [self getCrashLog];
    
    [dicLog setValue:crashReports forKey:@"Crash"];
}

+ (NSArray *)getCrashLog {
    if ([self hasCrashHappen]) {
        return [NSArray arrayWithContentsOfFile:[self pathCrashReport]];
    }
    return nil;
}

+ (void)delCrashLog {
    [[NSFileManager defaultManager] removeItemAtPath:[self pathCrashReport] error:nil];
}

+ (BOOL)hasCrashHappen{
    
    //是否有崩溃日志
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathCrashReport]])
        return YES;
    return NO;
}

+ (NSString *)getUseTime{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[CrashLogUtil pathStartEnd]]) {
        NSDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:[CrashLogUtil pathStartEnd]];
        NSDate *dateStart = (NSDate *)[dic objectForKey:@"startTime"];
        NSDate *dateEnd = (NSDate *)[dic objectForKey:@"endTime"];
        return [NSString stringWithFormat:@"%d",(int)[dateEnd timeIntervalSinceDate:dateStart]];
    }
    return @"";
}

+ (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    /*
     Possible values:
     "iPhone1,1" = iPhone 1G
     "iPhone1,2" = iPhone 3G
     "iPhone2,1" = iPhone 3GS
     "iPod1,1"   = iPod touch 1G
     "iPod2,1"   = iPod touch 2G
     */
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    return platform;
}

+ (void)writeCrashLog{

    //判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:[CrashLogUtil pathStartEnd]]) {
        NSMutableDictionary *dicLog = [NSMutableDictionary dictionaryWithCapacity:10];
        //app info
        NSDictionary *dicApp = [[NSBundle mainBundle] infoDictionary];
        [dicLog setValue:[dicApp objectForKey:@"CFBundleDisplayName"] forKey:@"AppName"];
        [dicLog setValue:[dicApp objectForKey:@"CFBundleVersion"] forKey:@"AppVer"];
        [dicLog setValue:@"ios" forKey:@"AppPlatform"];
        [dicLog setValue:[RTDeviceInfo channelId] forKey:@"AppPM"];
        //crash info
        BOOL hasCrash = [CrashLogUtil hasCrashHappen];

        if (hasCrash) {
            [self handleCrashReport:dicLog];
        }
        else
        {
            [dicLog setValue:@"" forKey:@"Crash"];
        }
        
        //device info
        UIDevice *device = [UIDevice currentDevice];
        [dicLog setValue:device.uniqueIdentifier forKey:@"DeviceID"];
//        [dicLog setValue:[delegate uuid] forKey:@"NewID"];
        [dicLog setValue:[self platform] forKey:@"Model"];
        [dicLog setValue:device.systemVersion forKey:@"OSVer"];
        
//        NSLog(@"%@,%@,%@,%@,%@",device.name,device.systemName,device.systemVersion,device.model,device.localizedModel);
        
        NSDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:[CrashLogUtil pathStartEnd]];
        NSDate *dateStart = (NSDate *)[dic objectForKey:@"startTime"];
        NSTimeInterval intervalStart = [dateStart timeIntervalSince1970];
        [dicLog setValue:[NSString stringWithFormat:@"%d",(int)intervalStart] forKey:@"start_date"];
        
        NSDate *dateEnd = (NSDate *)[dic objectForKey:@"endTime"];
        NSTimeInterval intervalEnd = [dateEnd timeIntervalSince1970];
        [dicLog setValue:[NSString stringWithFormat:@"%d",(int)intervalEnd] forKey:@"end_date"];
        
        //time info
        if (hasCrash) {
            [dicLog setValue:@"" forKey:@"UseTime"];
        }
        else
        {
            [dicLog setValue:[CrashLogUtil getUseTime] forKey:@"UseTime"];
        }
        
        //得到date的三个部分
        [dicLog setValue:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]] forKey:@"DateTime"];
        
        //write crash log
        NSString *logString = [dicLog JSONRepresentation];
        
        DLog(@"--------------------- crash log --------------------\n%@",logString);
        
        NSString *methodName = @"admin.writeCrashLog";        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:logString,@"log", nil];

        RTRequestProxy *_requestProxy = [RTRequestProxy sharedInstance];
        [_requestProxy asyncPostWithServiceID:RTAnjukeServiceID methodName:methodName params:params target:self action:@selector(requestFinished:)];
                
    }
    
    //log start time
    [CrashLogUtil logAppStart];
      
}

+ (void)requestFinished:(RTNetworkResponse *)response {
    DLog(@"response content:%@",[[response content] objectForKey:@"status"]);    
    if ([response status] == RTNetworkResponseStatusSuccess && 
        [[response content] objectForKey:@"status"] != nil && 
        [[(NSString *)[[response content] objectForKey:@"status"] uppercaseString] isEqualToString:@"OK"]) {
        [self delCrashLog];
    }
}

+ (void)saveCrash:(NSException *)exception {

//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    DLog(@"last:%@", delegate.lastAppearController);
    
    NSString *detail;
    if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
        detail = @"";
    }
    else {
        detail = [[exception callStackSymbols] componentsJoinedByString:@"\n"];
    }
    
    
//    NSString *reason = [NSString stringWithFormat:@"%@ [%@] [%@]",[exception reason],delegate.lastDisAppearController, delegate.lastAppearController];
    NSString *reason = [NSString stringWithFormat:@"%@",[exception reason]];
    
    NSString *name = [exception name];
    
    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    NSMutableDictionary *crash = [NSMutableDictionary dictionary];
    [crash setValue:reason forKey:@"Title"];
    [crash setValue:detail forKey:@"Detail"];
    [crash setValue:time forKey:@"Time"];
    [crash setValue:[self myNetworkStatus] forKey:@"Network"];
    
    NSMutableArray *crashReport;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathCrashReport]]) {
        crashReport = [NSMutableArray arrayWithContentsOfFile:[self pathCrashReport]];
    }
    else {
        crashReport = [NSMutableArray array];
    }
    [crashReport addObject:crash];
    [crashReport writeToFile:[self pathCrashReport] atomically:YES];
    

    NSString *log = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\ntime:\n%@\nreason:\n%@\ncallStackSymbols:\n%@", name,time,reason,detail];
    
    DLog(@"%@",log);
}

+ (NSString *)myNetworkStatus{
    return [[RTRequestProxy sharedInstance] getNetworkStatus];
}


@end
