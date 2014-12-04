//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Sergey on 16/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTaskRepair, STTTAgentTerminal, STTTTaskLocation;

@interface STTTAgentTask : STComment

@property (nonatomic, retain) NSDate * doBefore;
@property (nonatomic, retain) NSNumber * routePriority;
@property (nonatomic, retain) NSNumber * servstatus;
@property (nonatomic, retain) NSString * terminalBreakName;
@property (nonatomic, retain) NSSet *repairs;
@property (nonatomic, retain) STTTAgentTerminal *terminal;
@property (nonatomic, retain) STTTTaskLocation *visitLocation;
@end

@interface STTTAgentTask (CoreDataGeneratedAccessors)

- (void)addRepairsObject:(STTTAgentTaskRepair *)value;
- (void)removeRepairsObject:(STTTAgentTaskRepair *)value;
- (void)addRepairs:(NSSet *)values;
- (void)removeRepairs:(NSSet *)values;

@end
