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


- (NSNumber *)sectionNumber {
    
    double distance = [self.distance doubleValue];
    
    NSLog(@"distance %f", distance);
    
    if (distance < 1000) {
        return [NSNumber numberWithInt:0];
    } else if (distance >= 1000 && distance < 2000) {
        return [NSNumber numberWithInt:1];
    } else if (distance >= 2000 && distance < 5000) {
        return [NSNumber numberWithInt:2];
    } else if (distance >= 5000) {
        return [NSNumber numberWithInt:3];
    } else {
        return [NSNumber numberWithInt:0];
    }
    
}

//- (void)awakeFromFetch {
//    [super awakeFromFetch];
//    NSLog(@"awakeFromFetch");
//    [self calculateDistance];
//}
//
//- (void)awakeFromInsert {
//    [super awakeFromInsert];
//    NSLog(@"awakeFromInsert");
//    [self calculateDistance];
//}
//
//
//- (void)calculateDistance {
//    CLLocation *currentLocation = [[STTTLocationController sharedLC] currentLocation];
//    CLLocation *terminalLocation = [[CLLocation alloc] initWithLatitude:[self.location.latitude doubleValue] longitude:[self.location.longitude doubleValue]];
//    
//    if (!currentLocation || !terminalLocation) {
//        NSLog(@"0");
//        [self setPrimitiveValue:0 forKey:@"distance"];
//    } else {
//        CLLocationDistance distance = [currentLocation distanceFromLocation:terminalLocation];
//        NSLog(@"%f", distance);
//        [self setPrimitiveValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
//    }
//    
//}

@end
