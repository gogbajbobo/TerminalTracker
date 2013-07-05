//
//  STTTLocationController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTLocationController.h"

@interface STTTLocationController() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic, strong) NSMutableDictionary *settings;


@end


@implementation STTTLocationController

+ (STTTLocationController *)sharedLC {
    static dispatch_once_t pred = 0;
    __strong static id _sharedLC = nil;
    dispatch_once(&pred, ^{
        _sharedLC = [[self alloc] init];
    });
    return _sharedLC;
}

- (CLLocation *)currentLocation {
    return [[CLLocation alloc] initWithLatitude:55.806292 longitude:38.946073];
}


- (void)getLocation {
    [self.locationManager startUpdatingLocation];
//    NSLog(@"startUpdatingLocation");
}

//- (CLLocation *)currentLocation {
//    return [[CLLocation alloc] initWithLatitude:55.732829 longitude:38.951328];
//}

- (NSMutableDictionary *)settings {
    return [self.session.settingsController currentSettingsForGroup:@"location"];
}

- (CLLocationAccuracy) desiredAccuracy {
    return [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
}

- (double)requiredAccuracy {
    return [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
}


- (CLLocationDistance)distanceFilter {
    return [[self.settings valueForKey:@"distanceFilter"] doubleValue];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.desiredAccuracy = self.desiredAccuracy;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 5.0 &&
        newLocation.horizontalAccuracy > 0 &&
        newLocation.horizontalAccuracy <= self.requiredAccuracy) {
            self.currentLocation = newLocation;
            [self.locationManager stopUpdatingLocation];
//            NSLog(@"stopUpdatingLocation");
            self.locationManager = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationUpdated" object:self.currentLocation];
    }
    
}



@end
