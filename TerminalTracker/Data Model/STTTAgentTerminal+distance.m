//
//  STTTAgentTerminal+distance.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTerminal+distance.h"
#import "STTTLocationController.h"
#import "STTTTerminalLocation.h"

@implementation STTTAgentTerminal (distance)

- (void)awakeFromFetch {
    NSLog(@"awakeFromFetch");
    [self calculateDistance];
}

- (void)awakeFromInsert {
    NSLog(@"awakeFromInsert");
    [self calculateDistance];
}


- (void)calculateDistance {
    CLLocation *currentLocation = [[STTTLocationController sharedLC] currentLocation];
    CLLocation *terminalLocation = [[CLLocation alloc] initWithLatitude:[self.location.latitude doubleValue] longitude:[self.location.longitude doubleValue]];
    
    if (!currentLocation || !terminalLocation) {
//        NSLog(@"0");
        [self setPrimitiveValue:0 forKey:@"distance"];
    } else {
        CLLocationDistance distance = [currentLocation distanceFromLocation:terminalLocation];
//        NSLog(@"%f", distance);
        [self setPrimitiveValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
    }
    
}

@end
