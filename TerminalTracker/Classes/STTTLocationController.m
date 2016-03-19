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
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) NSTimeInterval timeFilter;


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

//- (CLLocation *)currentLocation {
//    NSLog(@"_currentLocation %@", _currentLocation);
//    return _currentLocation;
//}
//- (CLLocation *)currentLocation {
//    return [[CLLocation alloc] initWithLatitude:55.732829 longitude:38.951328];
//}



- (void)getLocation {
    
    if (self.currentLocation && [[NSDate date] timeIntervalSinceDate:self.currentLocation.timestamp] < self.timeFilter) {
        
//        NSLog(@"timeFilterLocation");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationUpdated" object:self.currentLocation];
        
    } else {
        
        [self.locationManager startUpdatingLocation];
//        NSLog(@"startUpdatingLocation");
        
    }
}

- (NSMutableDictionary *)settings {
    return [self.session.settingsController currentSettingsForGroup:@"location"];
}

- (CLLocationAccuracy) desiredAccuracy {
    return 100.0;
//    return [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
}

- (CLLocationAccuracy)requiredAccuracy {
    return 100.0;
//    return [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
}


- (CLLocationDistance)distanceFilter {
    return [[self.settings valueForKey:@"distanceFilter"] doubleValue];
}

- (NSTimeInterval)timeFilter {
    return [[self.settings valueForKey:@"timeFilter"] doubleValue];
}

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.desiredAccuracy = self.desiredAccuracy;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        
        if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            
            _locationManager.allowsBackgroundLocationUpdates = YES;
            NSLog(@"STTTLocationController allowsBackgroundLocationUpdates set");
            
        }

    }

//    NSLog(@"distanceFilter %f", _locationManager.distanceFilter);
//    NSLog(@"desiredAccuracy %f", _locationManager.desiredAccuracy);
    
    return _locationManager;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = locations.lastObject;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
//    NSLog(@"newLocation %@", newLocation);
    
    if (locationAge < 5.0) {
        
        if (newLocation.horizontalAccuracy > 0){
            
            self.currentAccuracy = newLocation.horizontalAccuracy;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentAccuracyUpdated" object:nil];
            
            if (newLocation.horizontalAccuracy <= self.requiredAccuracy) {
                
                self.currentLocation = newLocation;
                
                [self.locationManager stopUpdatingLocation];
//                NSLog(@"stopUpdatingLocation");
                self.locationManager = nil;
                
                NSString *logMessage = [NSString stringWithFormat:@"Location %@", self.currentLocation];
                [[(STSession *)self.session logger] saveLogMessageWithText:logMessage type:@""];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationUpdated" object:self.currentLocation];
                
            }
            
        }
        
    }
    
}



@end
