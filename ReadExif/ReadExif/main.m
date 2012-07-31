//
//  main.m
//  ReadExif
//
//  Created by zheng yan on 12-4-26.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "CrashLogUtil.h"

int main(int argc, char *argv[])
{
    @try {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
    @catch (NSException *exception) {
        [CrashLogUtil saveCrash:exception];
        
        @throw exception;
    }

}
