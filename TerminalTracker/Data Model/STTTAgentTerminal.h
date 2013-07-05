//
//  STTTAgentTerminal.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTask, STTTTerminalLocation;

@interface STTTAgentTerminal : STComment

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * errorText;
@property (nonatomic, retain) NSDate * lastActivityTime;
@property (nonatomic, retain) NSString * srcSystemName;
@property (nonatomic, retain) STTTTerminalLocation *location;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface STTTAgentTerminal (CoreDataGeneratedAccessors)

- (void)addTasksObject:(STTTAgentTask *)value;
- (void)removeTasksObject:(STTTAgentTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
