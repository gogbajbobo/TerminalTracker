//
//  STTTAgentTaskRepair.h
//  TerminalTracker
//
//  Created by Sergey on 15/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STTTAgentRepairCode, STTTAgentTask;

@interface STTTAgentTaskRepair : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) STTTAgentTask *task;
@property (nonatomic, retain) STTTAgentRepairCode *repairCode;

@end
