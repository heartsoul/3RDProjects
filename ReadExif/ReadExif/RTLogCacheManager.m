//
//  RTLogCacheManager.m
//  AnjukeBroker
//
//  Created by zheng yan on 12-5-31.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTLogCacheManager.h"
#import "AppLog.h"
#import "RTCoreDataManager.h"
#import "NSObject+SBJson.h"

@implementation RTLogCacheManager
@synthesize cachedLogs = _cachedLogs;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTLogCacheManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTLogCacheManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}
#pragma mark - RTLogger cache delegate
- (void)addLog:(NSString *)logString {
    NSManagedObject *log = [NSEntityDescription insertNewObjectForEntityForName:@"AppLog" inManagedObjectContext:[[RTCoreDataManager sharedInstance] managedObjectContext]];
    
    [(AppLog *)log setApplogJson:logString];
//    [self saveContext];
}

- (NSArray *)fetchLogs {
    NSManagedObjectContext *moc = [[RTCoreDataManager sharedInstance] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AppLog" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    // Set predicate and sort orderings...
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == YES", key];
    [request setPredicate:nil];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"applogJson" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSError *error = nil;
    self.cachedLogs = [moc executeFetchRequest:request error:&error];
    if (self.cachedLogs == nil)
    {
        // Deal with error...
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    NSMutableArray *dataArray = [[[NSMutableArray alloc] init] autorelease];
    for (id item in self.cachedLogs) {
        AppLog *log = (AppLog *)item;
        [dataArray addObject:[[log applogJson] JSONValue]];
        //        NSLog(@"from db: %@", [[log applogJson] JSONValue]);
    }
    
    
    return dataArray;
}

- (void)removeLogs {
    for (id log in self.cachedLogs)
        [[[RTCoreDataManager sharedInstance] managedObjectContext] deleteObject:log];
    
    [[RTCoreDataManager sharedInstance] saveContext];
}


@end
