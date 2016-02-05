//
//  STTTAgentTask.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTask.h"
#import "STTTAgentTaskComponent.h"
#import "STTTAgentTaskDefect.h"
#import "STTTAgentTaskRepair.h"
#import "STTTAgentTerminal.h"
#import "STTTTaskLocation.h"

#import "STTTSettingsController.h"


@implementation STTTAgentTask

- (NSTimeInterval)remainingTime {
    return [self.doBefore timeIntervalSinceDate:[NSDate date]];
}

- (int)numberOfTasksOnSameTerminal {
    
    int taskCount = 0;
    for (STTTAgentTask *task in self.terminal.tasks) {
        if (![task.servstatus boolValue] && self != task) {
            taskCount++;
        }
    }
    return taskCount;
    
}

- (BOOL)recentlyVisited {
    
    double time = [[[STTTSettingsController sharedSTTTSettingsController] getSettingValueForName:@"blockInterval" inGroup:@"general"] doubleValue];
    return self.visitLocation.cts && (fabs([self.visitLocation.cts timeIntervalSinceDate:[NSDate date]]) < time * 60);
    
}


@end
