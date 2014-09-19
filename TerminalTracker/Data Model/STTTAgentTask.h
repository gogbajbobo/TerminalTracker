//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Sergey on 18/9/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTerminal, STTTTaskLocation;

@interface STTTAgentTask : STComment

@property (nonatomic, retain) NSDate * doBefore;
@property (nonatomic, retain) NSNumber * servstatus;
@property (nonatomic, retain) NSString * terminalBreakName;
@property (nonatomic, retain) NSNumber * routePriority;
@property (nonatomic, retain) STTTAgentTerminal *terminal;
@property (nonatomic, retain) STTTTaskLocation *visitLocation;

@end
