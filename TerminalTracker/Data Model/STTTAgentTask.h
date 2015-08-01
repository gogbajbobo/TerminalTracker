//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTaskComponent, STTTAgentTaskDefect, STTTAgentTaskRepair, STTTAgentTerminal, STTTTaskLocation;

@interface STTTAgentTask : STComment

@property (nonatomic, retain) NSDate * doBefore;
@property (nonatomic, retain) NSNumber * routePriority;
@property (nonatomic, retain) NSNumber * servstatus;
@property (nonatomic, retain) NSDate * servstatusDate;
@property (nonatomic, retain) NSString * terminalBreakName;
@property (nonatomic, retain) NSSet *defects;
@property (nonatomic, retain) NSSet *repairs;
@property (nonatomic, retain) STTTAgentTerminal *terminal;
@property (nonatomic, retain) STTTTaskLocation *visitLocation;
@property (nonatomic, retain) NSSet *components;
@end

@interface STTTAgentTask (CoreDataGeneratedAccessors)

- (void)addDefectsObject:(STTTAgentTaskDefect *)value;
- (void)removeDefectsObject:(STTTAgentTaskDefect *)value;
- (void)addDefects:(NSSet *)values;
- (void)removeDefects:(NSSet *)values;

- (void)addRepairsObject:(STTTAgentTaskRepair *)value;
- (void)removeRepairsObject:(STTTAgentTaskRepair *)value;
- (void)addRepairs:(NSSet *)values;
- (void)removeRepairs:(NSSet *)values;

- (void)addComponentsObject:(STTTAgentTaskComponent *)value;
- (void)removeComponentsObject:(STTTAgentTaskComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

@end
