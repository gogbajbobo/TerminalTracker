//
//  STTTAgentDefectCode.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 21/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTaskDefect;

@interface STTTAgentDefectCode : STComment

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *taskDefects;
@end

@interface STTTAgentDefectCode (CoreDataGeneratedAccessors)

- (void)addTaskDefectsObject:(STTTAgentTaskDefect *)value;
- (void)removeTaskDefectsObject:(STTTAgentTaskDefect *)value;
- (void)addTaskDefects:(NSSet *)values;
- (void)removeTaskDefects:(NSSet *)values;

@end
