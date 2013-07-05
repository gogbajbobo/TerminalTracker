//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTerminal, STTTTaskLocation;

@interface STTTAgentTask : STComment

@property (nonatomic, retain) NSDate * doBefore;
@property (nonatomic, retain) NSString * terminalBreakName;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) STTTAgentTerminal *terminal;
@property (nonatomic, retain) STTTTaskLocation *visitLocation;

@end
