//
//  STTTAgentTask.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 21/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTask.h"
#import "STTTAgentTaskDefect.h"
#import "STTTAgentTaskRepair.h"
#import "STTTAgentTerminal.h"
#import "STTTTaskLocation.h"


@implementation STTTAgentTask

@dynamic doBefore;
@dynamic routePriority;
@dynamic servstatus;
@dynamic servstatusDate;
@dynamic terminalBreakName;
@dynamic repairs;
@dynamic terminal;
@dynamic visitLocation;
@dynamic defects;

@end
