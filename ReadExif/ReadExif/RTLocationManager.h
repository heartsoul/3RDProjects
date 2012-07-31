//
//  RTLocationManager.h
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RTLogger.h"

@interface RTLocationManager : NSObject <CLLocationManagerDelegate, RTLoggerLocationDelegate>

+ (id)sharedInstance;
- (id)init;

@property (nonatomic, readonly) CLLocation *userLocation;
@property (nonatomic, retain) CLLocation *mapUserLocation;    // use user location in MKMapView. 
@property (nonatomic, copy) NSString *locatedCityID;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;
- (BOOL)locationServicesEnabled;
- (void)updateLocatedCityID;

@end
