//
//  STTTAgentTask+cellcoloring.m
//  TerminalTracker
//
//  Created by Sergey on 23/9/2014.
//  Copyright (c) 2014 Sergey Dvornikov. All rights reserved.
//

#import "STTTAgentTask+cellcoloring.h"

@implementation STTTAgentTask (cellcoloring)
- (UIColor *)getBackgroundColorForDisplaying {
    if ([self.servstatus intValue] == 1) {
        return [UIColor lightGrayColor];
    }
    UIColor* textColor = [UIColor whiteColor];
    switch ([self.routePriority intValue]) {
        case 3:
            textColor = [UIColor redColor];
            break;
        case 2:
            textColor = [UIColor yellowColor];
            break;
        case 1:
            textColor = [UIColor greenColor];
            break;
    }
    return textColor;
}

-(UIColor *)getTextColorForDisplaying {
    if ([self.servstatus intValue] == 1) {
        return [UIColor darkGrayColor];
    }
    UIColor* textColor = [UIColor blackColor];
    switch ([self.routePriority intValue]) {
        case 3:
            textColor = [UIColor whiteColor];
            break;
    }
    return textColor;
}

@end
