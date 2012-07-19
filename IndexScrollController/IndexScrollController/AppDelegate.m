//
//  AppDelegate.m
//  IndexScrollController
//
//  Created by zheng yan on 12-7-18.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "AppDelegate.h"
#import "ContentViewController.h"
#import "IndexScrollController.h"
#import "IndexScrollView.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // init content controllers
    NSMutableArray *contentControllers = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        ContentViewController *controller = [[ContentViewController alloc] init];
        controller.pageNumber = i;
        controller.title = [NSString stringWithFormat:@"Page %d", i];
        controller.view.frame = CGRectMake(0, 0, 320, 416-INDEX_SCROLL_VIEW_HEIGHT);
        [contentControllers addObject:controller];
        [controller release];
    }

    // fill in a navigation controller
    IndexScrollController *scrollController = [[IndexScrollController alloc] init];
    scrollController.contentControllers = contentControllers;
    scrollController.title = @"Index Scroll Demo";

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scrollController];
    self.window.rootViewController = navController;
    
    [navController release];
    
//    self.window.backgroundColor = [UIColor whiteColor];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
