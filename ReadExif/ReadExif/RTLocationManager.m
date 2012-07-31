//
//  RTLocationManager.m
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTLocationManager.h"
#import "RTNetwork.h"

@implementation RTLocationManager
@synthesize locationManager = _locationManager;
@synthesize userLocation = _userLocation;
@synthesize mapUserLocation = _mapUserLocation;
@synthesize locatedCityID = _locatedCityID;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTLocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTLocationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 1000;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

- (CLLocation *)userLocation {
    if (self.locationManager.location == nil)
        [self restartLocation];
    
//    NSLog(@"cur: lat: %f, lng: %f, timestamp:%@", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.latitude, self.locationManager.location.timestamp);
    
    return self.locationManager.location;
}

- (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (void)restartLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
}


- (void)startLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }    
}

- (void)stopLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    }        
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    DLog(@"new: lat: %f, lng: %f, timestamp:%@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.timestamp);
    [self updateLocatedCityID];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (CLLocation *)mapUserLocation {       
    if (!_mapUserLocation)
        _mapUserLocation = [[CLLocation alloc] init] autorelease];
    
    _mapUserLocation.coordinate = self.userLocation.coordinate;
    return  _mapUserLocation;
}

#pragma mark - Update GPS city
// click nearby will call this method
- (void)updateLocatedCityID {
    CLLocation *userLocation =  self.userLocation;
    NSString *lat = [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:lat, @"lat", lng, @"lng", nil];
    [[RTRequestProxy sharedInstance] asyncGetWithServiceID:RTAnjukeServiceID methodName:@"location.getCity" params:params target:self action:@selector(getLocationCityFinish:)];
}

- (void)getLocationCityFinish:(RTNetworkResponse *)response {
    if (response.status != RTNetworkResponseStatusSuccess)
        return;
    
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        self.locatedCityID = [[response.content objectForKey:@"city"] objectForKey:@"id"];
        DLog(@"Located cityID: %@", self.locatedCityID);
    }
}


@end
