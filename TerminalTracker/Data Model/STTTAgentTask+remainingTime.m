//
//  STTTAgentTask+remainingTime.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTask+remainingTime.h"

@implementation STTTAgentTask (remainingTime)

- (NSTimeInterval)remainingTime {
    NSDate *currentDate = [NSDate date];
    return [currentDate timeIntervalSinceDate:self.doBefore];
}

@end
