//
//  STTTLocationController.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <STManagedTracker/STSession.h>

@interface STTTLocationController : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) STSession *session;

- (void)getLocation:(void (^)(BOOL success))completionHandler;


@end
