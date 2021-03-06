//
//  AppDelegate.m
//  ReadExif
//
//  Created by zheng yan on 12-4-26.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "RTCoreDataManager.h"
#import "RTLogger.h"
#import "RTLocationManager.h"
#import "RTLogCacheManager.h"
#import "RTDeviceInfo.h"
#import "CrashLogUtil.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CrashLogUtil writeCrashLog];

    // init RTManagers
    [[RTCoreDataManager sharedInstance] setModelName:@"ReadExif"];
    
    [[RTLogger sharedInstance] setCacheDelegate:[RTLogCacheManager sharedInstance]];
    [[RTLogger sharedInstance] setInfoDelegate:[RTLocationManager sharedInstance]];
    [[RTLogger sharedInstance] setLogAppName:@"i-crashtest"];
    
    [[RTRequestProxy sharedInstance] setChannelID:[RTDeviceInfo channelId]];
    [[RTRequestProxy sharedInstance] setLogger:[RTLogger sharedInstance]];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [CrashLogUtil logAppEnd];
    [[RTLogger sharedInstance] logAppEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [CrashLogUtil writeCrashLog];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[RTLocationManager sharedInstance] restartLocation];
    
    [CrashLogUtil logAppStart];
    [[RTLogger sharedInstance] logAppBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
