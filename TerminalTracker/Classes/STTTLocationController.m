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

- (void)getLocation:(void (^)(BOOL))completionHandler {
    
    completionHandler(YES);
}


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




@end
