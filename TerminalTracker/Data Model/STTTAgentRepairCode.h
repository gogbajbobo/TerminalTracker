//
//  STTTAgentRepairCode.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 15/05/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTaskRepair;

@interface STTTAgentRepairCode : STComment

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * repairName;
@property (nonatomic, retain) NSSet *taskRepairs;
@end

@interface STTTAgentRepairCode (CoreDataGeneratedAccessors)

- (void)addTaskRepairsObject:(STTTAgentTaskRepair *)value;
- (void)removeTaskRepairsObject:(STTTAgentTaskRepair *)value;
- (void)addTaskRepairs:(NSSet *)values;
- (void)removeTaskRepairs:(NSSet *)values;

@end
