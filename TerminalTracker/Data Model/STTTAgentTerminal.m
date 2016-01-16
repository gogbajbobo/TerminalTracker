//
//  STTTAgentTerminal.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 16/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTerminal.h"
#import "STTTAgentTask.h"
#import "STTTTerminalLocation.h"

//#import "STTTLocationController.h"


@implementation STTTAgentTerminal

- (NSNumber *)sectionNumber {
    
    double distance = [self.distance doubleValue];
    
    //    NSLog(@"distance %f", distance);
    
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
